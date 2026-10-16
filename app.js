// JanSahay backend app (Express). Used by backend/server.js on localhost and by api/index.js on Vercel.
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const express = require('express');
const cookieParser = require('cookie-parser');
const { requireAuth, pageGuard, readUser } = require('./src/auth');

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 16) throw new Error('Missing JWT_SECRET (16+ characters). Set it in backend/.env or in the Vercel project settings.');
if (!process.env.DATABASE_URL) throw new Error('Missing DATABASE_URL. Set it in backend/.env or in the Vercel project settings.');

const app = express();
const FRONT = path.join(__dirname, '..', 'frontend');

app.disable('x-powered-by');
app.set('trust proxy', 1);   // behind Vercel's proxy: correct client IP and https detection
app.use((req, res, next) => {
  res.set({
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'Referrer-Policy': 'same-origin',
    'Content-Security-Policy': "default-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src https://fonts.gstatic.com; img-src 'self' data:; frame-ancestors 'none'"
  });
  next();
});
app.use(express.json({ limit: '50kb' }));
app.use(cookieParser());

// static assets (public) and API
app.use('/css', express.static(path.join(FRONT, 'css')));
app.use('/js', express.static(path.join(FRONT, 'js')));
app.use('/api/auth', require('./src/routes/auth'));
app.use('/api/schemes', requireAuth, require('./src/routes/schemes'));
app.use('/api/me', requireAuth, require('./src/routes/me'));
app.use('/api', (req, res) => res.status(404).json({ error: 'Not found' }));

// pages: the site opens on the sign-in page (JanSahayak); the app itself (JanSahay) needs a valid session
app.get('/', (req, res) => res.redirect(readUser(req) ? '/app' : '/login'));
app.get('/login', (req, res) => readUser(req) ? res.redirect('/app') : res.sendFile(path.join(FRONT, 'login.html')));
app.get('/app', pageGuard, (req, res) => res.sendFile(path.join(FRONT, 'index.html')));
app.use((req, res) => res.status(404).send('Not found'));

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Server error' });
});

module.exports = app;
