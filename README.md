# JanSahay – Government Scheme Finder

The sign-in (landing) page is branded **JanSahayak**; the app after sign-in is **JanSahay**.

    frontend/   login page, app pages, CSS, JS (served by the backend)
    backend/    Express API: sign-in, profile, eligibility matching, document vault, reminders
    database/   PostgreSQL schema.sql and seed.sql (18 schemes with eligibility rules and documents)
    api/        Vercel entry point (api/index.js) + vercel.json at the root

Flow: open the site -> JanSahayak sign-in page -> create account or sign in -> app at /app.

## Run on your computer (Windows)

1. Install Node.js and PostgreSQL. Create an empty database named `sahayak` (psql: `CREATE DATABASE sahayak;`).
2. In `backend`, copy `.env.example` to `.env`, then set `DATABASE_URL` (your Postgres password) and `JWT_SECRET` (any long random text).
3. In this folder run:

       npm install
       npm run db:init     (creates tables and loads schemes; safe to re-run, never deletes users)
       npm run dev         (http://localhost:8000)

## Put it live on Vercel

You need a hosted PostgreSQL database, because Vercel has no database or disk of its own. Neon has a free plan.

1. **Database:** create a project at neon.tech (or in Vercel: Storage > Create > Neon) and copy the connection string
   (use the pooled one; it ends with `?sslmode=require`).
2. **Create the tables in that database, once, from your computer:** paste the string into `backend/.env` as `DATABASE_URL`, then run `npm run db:init`.
3. **GitHub:** push this folder to a new GitHub repository. (`.env` and `node_modules` are ignored automatically.)
4. **Vercel:** vercel.com > Add New > Project > import the repository.
   - Framework Preset: **Other**. Root Directory: the folder that contains `vercel.json`.
   - Environment Variables: `DATABASE_URL` (the connection string) and `JWT_SECRET` (a long random text). Vercel sets `NODE_ENV=production` itself.
   - Click Deploy. Your site opens at `https://<project-name>.vercel.app`, starting on the JanSahayak sign-in page.
5. Later changes: push to GitHub and Vercel redeploys. Run `npm run db:init` again only when `database/` changes.

Using the CLI instead: `npm i -g vercel`, `vercel login`, `vercel`, `vercel env add DATABASE_URL`, `vercel env add JWT_SECRET`, `vercel --prod`.

How it differs from localhost: uploaded files are stored in the database (not on disk), each file is limited to 4 MB (Vercel caps a request at 4.5 MB),
and the sign-in attempt limiter is per server instance, so it is only a light brake.

## API (JSON; everything except /api/auth/* needs the sign-in cookie)

    POST /api/auth/register {name,mobile,password}   POST /api/auth/login {mobile,password}   POST /api/auth/logout
    GET  /api/schemes
    GET  /api/me                      DELETE /api/me   (delete account and files)
    PUT  /api/me/profile              GET /api/me/matches    GET /api/me/recommendations    DELETE /api/me/recommendations/:code
    GET/POST /api/me/alerts           DELETE /api/me/alerts/:id
    GET/POST /api/me/documents        GET /api/me/documents/:id/file    DELETE /api/me/documents/:id

## Change the schemes

Edit rows in the database, or edit `database/seed.sql` and run `npm run db:init` (it rebuilds all rules and required documents).
A rule row is one way to qualify: `level` 2 (likely eligible) or 1 (check at office); empty columns mean "any";
`required_flags` lists profile flags that must be true (bpl, disability, pregnant, daughter_u10, no_pucca_house, owns_land).

## Before sharing the public link

This site stores personal documents such as Aadhaar. Until it has HTTPS-only hosting you trust, a privacy policy and consent flow
that meets the DPDP Act 2023, encrypted storage and backups, treat it as a demo and do not upload real documents.
Not built yet: password reset, OTP / mobile verification, SMS or WhatsApp reminders, DigiLocker verification, scheduled reminders.
Eligibility rules are simplified from published criteria and department names in `seed.sql` are approximate; check them against the official portals.
