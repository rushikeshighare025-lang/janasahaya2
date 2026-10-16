// Creates the tables and loads the scheme data:  npm run db:init   (safe to re-run; it never deletes citizens)
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });
const { Pool } = require('pg');

(async () => {
  if (!process.env.DATABASE_URL) { console.error('Set DATABASE_URL in backend/.env first'); process.exit(1); }
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  try {
    for (const f of ['schema.sql', 'seed.sql']) {
      await pool.query(fs.readFileSync(path.join(__dirname, '..', '..', 'database', f), 'utf8'));
      console.log('ran database/' + f);
    }
    console.log('Database ready.');
  } catch (e) {
    console.error('Database setup failed:', e.message);
    process.exitCode = 1;
  } finally { await pool.end(); }
})();
