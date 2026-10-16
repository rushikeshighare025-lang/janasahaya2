const router = require('express').Router();
const db = require('../db');

// All active schemes with their required documents. Names and benefits come in English, Hindi and Marathi.
router.get('/', async (req, res, next) => {
  try {
    const { rows } = await db.query(`
      SELECT s.code, s.scheme_name AS name, s.name_hi, s.name_mr,
             s.benefits, s.benefits_hi, s.benefits_mr, s.category, s.state, s.hide_in_state, s.application_url,
             COALESCE(array_agg(d.document_name ORDER BY d.document_id) FILTER (WHERE d.document_id IS NOT NULL), ARRAY[]::text[]) AS docs
      FROM schemes s LEFT JOIN documents d ON d.scheme_id = s.scheme_id
      WHERE s.status = 'active'
      GROUP BY s.scheme_id ORDER BY s.scheme_id`);
    res.json(rows);
  } catch (e) { next(e); }
});

module.exports = router;
