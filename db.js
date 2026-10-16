const { Pool } = require('pg');
// On Vercel each function instance keeps only a few connections; use your database's pooled connection string.
module.exports = new Pool({ connectionString: process.env.DATABASE_URL, max: process.env.VERCEL ? 3 : 10 });
