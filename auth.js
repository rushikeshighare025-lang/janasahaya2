const router = require('express').Router();
const bcrypt = require('bcryptjs');
const db = require('../db');
const { COOKIE, setCookie } = require('../auth');

const wrap = fn => (req, res, next) => fn(req, res, next).catch(next);
const MOBILE = /^[6-9]\d{9}$/;

// tiny in-memory throttle: max 10 failed attempts per key per 15 minutes
const fails = new Map();
const recent = k => { const now = Date.now(), a = (fails.get(k) || []).filter(t => now - t < 15 * 60e3); fails.set(k, a); return a; };
const bad = (res, status, code, error) => res.status(status).json({ error, code });

router.post('/register', wrap(async (req, res) => {
  const name = String(req.body.name || '').trim(), mobile = String(req.body.mobile || '').trim(), password = String(req.body.password || '');
  if (name.length < 2 || name.length > 100 || !MOBILE.test(mobile) || password.length < 8 || password.length > 72)
    return bad(res, 400, 'validation', 'Enter your name, a valid 10-digit mobile number and a password of 8 to 72 characters');
  const ipKey = 'reg' + req.ip;
  if (recent(ipKey).length >= 10) return bad(res, 429, 'limited', 'Too many attempts. Try again later.');
  recent(ipKey).push(Date.now());
  try {
    const hash = await bcrypt.hash(password, 10);
    const { rows } = await db.query('INSERT INTO citizens (name, mobile, password_hash) VALUES ($1,$2,$3) RETURNING citizen_id', [name, mobile, hash]);
    setCookie(res, rows[0].citizen_id);
    res.json({ ok: true });
  } catch (e) {
    if (e.code === '23505') return bad(res, 409, 'exists', 'This mobile number is already registered');
    throw e;
  }
}));

router.post('/login', wrap(async (req, res) => {
  const mobile = String(req.body.mobile || '').trim(), password = String(req.body.password || '');
  const key = req.ip + mobile;
  if (recent(key).length >= 10) return bad(res, 429, 'limited', 'Too many attempts. Try again in 15 minutes.');
  const { rows } = await db.query('SELECT citizen_id, password_hash FROM citizens WHERE mobile = $1', [mobile]);
  const ok = rows[0] && await bcrypt.compare(password, rows[0].password_hash);
  if (!ok) { recent(key).push(Date.now()); return bad(res, 401, 'invalid', 'Wrong mobile number or password'); }
  fails.delete(key);
  setCookie(res, rows[0].citizen_id);
  res.json({ ok: true });
}));

router.post('/logout', (req, res) => { res.clearCookie(COOKIE); res.json({ ok: true }); });

module.exports = router;
