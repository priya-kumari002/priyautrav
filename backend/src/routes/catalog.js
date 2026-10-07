const express = require('express');
const { pool } = require('../db');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.get('/transports', authRequired, async (_req, res) => {
  const { rows } = await pool.query(
    `SELECT code, label, icon_key FROM transport_types ORDER BY id`
  );
  res.json(rows);
});

router.get('/recent-locations', authRequired, async (req, res) => {
  const { rows } = await pool.query(
    `SELECT id, label, address FROM recent_locations
     WHERE user_id = $1 ORDER BY used_at DESC LIMIT 10`,
    [req.user.userId]
  );
  res.json(rows);
});

module.exports = router;
