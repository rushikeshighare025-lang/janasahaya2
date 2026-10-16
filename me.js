// Everything about the signed-in citizen: profile, eligibility matches, recommendations, reminders, documents.
const router = require('express').Router();
const path = require('path');
const multer = require('multer');
const db = require('../db');

const wrap = fn => (req, res, next) => fn(req, res, next).catch(next);
const INCOME_MAX = [1e5, 2.5e5, 5e5, 8e5, 1e9];               // income band index -> upper bound used by rules
const FLAGS = { bpl: 'bpl', disab: 'disability', preg: 'pregnant', dau: 'daughter_u10', nohouse: 'no_pucca_house', land: 'owns_land' };
const OCC = ['farmer', 'student', 'vendor', 'worker', 'homemaker', 'other'];
const CAT = ['General', 'OBC', 'SC', 'ST'];
const LANG = ['en', 'hi', 'mr'];
const EDU = ['below10', '10', '12', 'diploma', 'grad', 'pg', 'other'];
const EMP = ['unemployed', 'employed', 'self', 'student', 'retired'];
const DOC_TYPES = ['aadhaar', 'ration', 'ls', 'marks', 'caste', 'income', 'domicile', 'bank', 'land', 'udid', 'birth'];
const bad = (res, error, status = 400) => res.status(status).json({ error });

/* ---------- profile ---------- */
function toProfile(c) {
  const p = {
    name: c.name, state: c.state || 'Maharashtra', age: c.age ?? 20, gender: c.gender || 'f',
    inc: c.income_band ?? 1, occ: c.occupation || 'student', cat: c.category || 'General', nt: +c.notify_enabled,
    district: c.district || '', edu: c.education_level || '', emp: c.employment_status || '', email: c.email || '', fam: c.family_size || ''
  };
  for (const k in FLAGS) p[k] = +c[FLAGS[k]];
  return p;
}

router.get('/', wrap(async (req, res) => {
  const { rows } = await db.query('SELECT * FROM citizens WHERE citizen_id = $1', [req.userId]);
  if (!rows[0]) return bad(res, 'Please sign in', 401);
  res.json({ id: rows[0].citizen_id, name: rows[0].name, mobile: rows[0].mobile, profile: toProfile(rows[0]), profile_complete: rows[0].profile_complete });
}));

// Eligibility is computed in SQL from eligibility_rules. A scheme's level is the best level among the rules the citizen satisfies
// (2 = likely eligible, 1 = check at office). Empty rule columns mean "no restriction".
async function levelsFor(id) {
  const { rows } = await db.query(`
    SELECT s.code, MAX(r.level) AS level
    FROM schemes s
    JOIN eligibility_rules r ON r.scheme_id = s.scheme_id
    JOIN citizens c ON c.citizen_id = $1
    WHERE s.status = 'active'
      AND (s.state = 'All India' OR s.state = c.state)
      AND (s.hide_in_state IS NULL OR s.hide_in_state <> c.state)
      AND (r.min_age IS NULL OR c.age >= r.min_age)
      AND (r.max_age IS NULL OR c.age <= r.max_age)
      AND (r.max_income IS NULL OR c.income <= r.max_income)
      AND (r.occupation IS NULL OR r.occupation = c.occupation)
      AND (r.state IS NULL OR r.state = c.state)
      AND (r.category IS NULL OR r.category = c.category)
      AND (r.gender IS NULL OR r.gender = c.gender)
      AND (r.education_level IS NULL OR r.education_level = c.education_level)
      AND (r.employment_status IS NULL OR r.employment_status = c.employment_status)
      AND (r.required_flags IS NULL OR r.required_flags <@ array_remove(ARRAY[
            CASE WHEN c.bpl THEN 'bpl' END, CASE WHEN c.disability THEN 'disability' END,
            CASE WHEN c.pregnant THEN 'pregnant' END, CASE WHEN c.daughter_u10 THEN 'daughter_u10' END,
            CASE WHEN c.no_pucca_house THEN 'no_pucca_house' END, CASE WHEN c.owns_land THEN 'owns_land' END
          ]::text[], NULL::text))
    GROUP BY s.code`, [id]);
  const out = {};
  rows.forEach(r => { out[r.code] = Number(r.level); });
  return out;
}

async function feedFor(id) {
  const { rows } = await db.query(`SELECT s.code FROM recommendations r JOIN schemes s ON s.scheme_id = r.scheme_id
    WHERE r.citizen_id = $1 AND r.recommendation_status = 'new' ORDER BY r.created_at`, [id]);
  return rows.map(r => r.code);
}

router.put('/profile', wrap(async (req, res) => {
  const b = req.body || {};
  const age = Number(b.age), inc = Number(b.inc);
  if (!Number.isInteger(age) || age < 0 || age > 120) return bad(res, 'Enter a valid age');
  if (!['m', 'f', 'o'].includes(b.gender) || !Number.isInteger(inc) || inc < 0 || inc > 4 ||
      !OCC.includes(b.occ) || !CAT.includes(b.cat) || typeof b.state !== 'string' || !b.state || b.state.length > 100)
    return bad(res, 'Invalid profile details');
  const name = String(b.name || '').trim().slice(0, 100);
  const district = String(b.district || '').trim().slice(0, 100);
  const email = String(b.email || '').trim().slice(0, 150);
  const edu = b.edu || null, emp = b.emp || null;
  const fam = (b.fam === '' || b.fam == null) ? null : Number(b.fam);
  if ((edu && !EDU.includes(edu)) || (emp && !EMP.includes(emp))) return bad(res, 'Invalid education or employment choice');
  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return bad(res, 'Enter a valid email address');
  if (fam !== null && (!Number.isInteger(fam) || fam < 1 || fam > 30)) return bad(res, 'Family members must be between 1 and 30');
  const f = {}; for (const k in FLAGS) f[k] = !!b[k];
  await db.query(`UPDATE citizens SET name = COALESCE(NULLIF($2,''), name), age=$3, gender=$4, income=$5, income_band=$6,
      occupation=$7, state=$8, category=$9, language=$10, bpl=$11, disability=$12, pregnant=$13, daughter_u10=$14,
      no_pucca_house=$15, owns_land=$16, notify_enabled=$17, district=NULLIF($18,''), education_level=$19,
      employment_status=$20, email=NULLIF($21,''), family_size=$22, profile_complete=TRUE WHERE citizen_id=$1`,
    [req.userId, name, age, b.gender, INCOME_MAX[inc], inc, b.occ, b.state, b.cat, LANG[b.lang] || 'en',
     f.bpl, f.disab, f.preg, f.dau, f.nohouse, f.land, !!b.nt, district, edu, emp, email, fam]);

  const levels = await levelsFor(req.userId);
  const strong = Object.keys(levels).filter(c => levels[c] === 2);
  let fresh = [];
  if (strong.length) {   // a recommendation row is created once per scheme, so each match notifies only once
    const r = await db.query(`WITH ins AS (
        INSERT INTO recommendations (citizen_id, scheme_id, match_score, reason, recommendation_status)
        SELECT $1, scheme_id, 90, 'Matches your profile', 'new' FROM schemes WHERE code = ANY($2)
        ON CONFLICT (citizen_id, scheme_id) DO NOTHING RETURNING scheme_id)
      SELECT s.code FROM ins JOIN schemes s ON s.scheme_id = ins.scheme_id`, [req.userId, strong]);
    fresh = r.rows.map(x => x.code);
  }
  res.json({ levels, fresh, feed: await feedFor(req.userId) });
}));

router.get('/matches', wrap(async (req, res) => res.json(await levelsFor(req.userId))));
router.get('/recommendations', wrap(async (req, res) => res.json(await feedFor(req.userId))));
router.delete('/recommendations/:code', wrap(async (req, res) => {
  await db.query(`UPDATE recommendations SET recommendation_status = 'dismissed'
    WHERE citizen_id = $1 AND scheme_id = (SELECT scheme_id FROM schemes WHERE code = $2)`, [req.userId, req.params.code]);
  res.json({ ok: true });
}));

/* ---------- reminders (alerts table) ---------- */
const ALERT_SQL = `SELECT a.alert_id AS k, s.code AS id, to_char(a.alert_date, 'YYYY-MM-DD') AS d
  FROM alerts a JOIN schemes s ON s.scheme_id = a.scheme_id WHERE a.citizen_id = $1 AND a.alert_type = 'reminder'`;
router.get('/alerts', wrap(async (req, res) => res.json((await db.query(ALERT_SQL + ' ORDER BY a.alert_date', [req.userId])).rows)));
router.post('/alerts', wrap(async (req, res) => {
  const code = String(req.body.code || ''), date = String(req.body.date || '');
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date) || isNaN(new Date(date))) return bad(res, 'Invalid date');
  const n = (await db.query(`SELECT count(*)::int AS n FROM alerts WHERE citizen_id = $1`, [req.userId])).rows[0].n;
  if (n >= 100) return bad(res, 'Too many reminders');
  const r = await db.query(`INSERT INTO alerts (citizen_id, scheme_id, alert_type, alert_date, message)
    SELECT $1, scheme_id, 'reminder', $3, 'Scheme reminder' FROM schemes WHERE code = $2 RETURNING alert_id`, [req.userId, code, date]);
  if (!r.rows[0]) return bad(res, 'Unknown scheme', 404);
  res.json({ k: r.rows[0].alert_id, id: code, d: date });
}));
router.delete('/alerts/:id', wrap(async (req, res) => {
  await db.query('DELETE FROM alerts WHERE alert_id = $1 AND citizen_id = $2', [parseInt(req.params.id, 10) || 0, req.userId]);
  res.json({ ok: true });
}));

/* ---------- document vault ----------
   Files are stored in the database (citizen_documents.file_data), so this also works on Vercel, which has no persistent disk.
   Vercel limits a request body to 4.5 MB, so each file is capped at 4 MB and the browser uploads one file per request. */
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 4 * 1024 * 1024, files: 5 } }).array('files', 5);

function sniff(b) {   // trust the bytes, not the filename or the browser's claim
  if (b.length < 8) return null;
  if (b.slice(0, 4).toString() === '%PDF') return 'application/pdf';
  if (b[0] === 0xFF && b[1] === 0xD8 && b[2] === 0xFF) return 'image/jpeg';
  if (b.slice(0, 4).equals(Buffer.from([0x89, 0x50, 0x4E, 0x47]))) return 'image/png';
  return null;
}

router.get('/documents', wrap(async (req, res) => {
  const { rows } = await db.query(`SELECT citizen_document_id AS id, document_name AS type, original_name AS name, size_bytes AS size
    FROM citizen_documents WHERE citizen_id = $1 ORDER BY uploaded_at`, [req.userId]);
  res.json(rows);
}));

router.post('/documents', (req, res, next) => upload(req, res, err => {
  if (err) return bad(res, err.code === 'LIMIT_FILE_SIZE' ? 'File is larger than 4 MB' : 'Upload failed');
  next();
}), wrap(async (req, res) => {
  const files = req.files || [], type = String(req.body.type || '');
  if (!DOC_TYPES.includes(type)) return bad(res, 'Unknown document type');
  const n = (await db.query('SELECT count(*)::int AS n FROM citizen_documents WHERE citizen_id = $1', [req.userId])).rows[0].n;
  if (n + files.length > 40) return bad(res, 'Document limit reached (40 files)');
  let saved = 0, rejected = 0;
  for (const f of files) {
    const mime = sniff(f.buffer);
    if (!mime) { rejected++; continue; }
    const original = path.basename(Buffer.from(f.originalname, 'latin1').toString('utf8')).slice(0, 150);
    await db.query(`INSERT INTO citizen_documents (citizen_id, document_name, original_name, mime_type, size_bytes, document_path, file_data, status, verified)
      VALUES ($1,$2,$3,$4,$5,'db',$6,'uploaded',FALSE)`, [req.userId, type, original, mime, f.size, f.buffer]);
    saved++;
  }
  if (!saved) return bad(res, 'Only PDF, JPG or PNG files are allowed');
  res.json({ saved, rejected });
}));

router.get('/documents/:id/file', wrap(async (req, res) => {
  const { rows } = await db.query(`SELECT file_data, mime_type, original_name FROM citizen_documents
    WHERE citizen_document_id = $1 AND citizen_id = $2`, [parseInt(req.params.id, 10) || 0, req.userId]);
  if (!rows[0] || !rows[0].file_data) return bad(res, 'Not found', 404);
  res.set({ 'Content-Type': rows[0].mime_type, 'Content-Disposition': "inline; filename*=UTF-8''" + encodeURIComponent(rows[0].original_name),
            'Content-Security-Policy': 'sandbox', 'Cache-Control': 'private, no-store' });
  res.send(rows[0].file_data);
}));
router.delete('/documents/:id', wrap(async (req, res) => {
  await db.query('DELETE FROM citizen_documents WHERE citizen_document_id = $1 AND citizen_id = $2', [parseInt(req.params.id, 10) || 0, req.userId]);
  res.json({ ok: true });
}));

/* ---------- delete my account (profile, reminders, recommendations and all uploaded files) ---------- */
router.delete('/', wrap(async (req, res) => {
  await db.query('DELETE FROM citizens WHERE citizen_id = $1', [req.userId]);   // cascades to the other tables
  res.clearCookie(require('../auth').COOKIE);
  res.json({ ok: true });
}));

module.exports = router;
