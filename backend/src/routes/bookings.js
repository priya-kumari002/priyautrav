const express = require('express');
const { body, validationResult } = require('express-validator');
const { pool } = require('../db');
const { authRequired } = require('../middleware/auth');

const router = express.Router();

router.post(
  '/',
  authRequired,
  body('transportCode').isString().notEmpty(),
  body('pickupAddress').isString().isLength({ min: 3 }),
  body('dropoffAddress').isString().isLength({ min: 3 }),
  body('senderName').isString().isLength({ min: 2 }),
  body('senderPhone').isString().isLength({ min: 10 }),
  body('receiverName').isString().isLength({ min: 2 }),
  body('receiverPhone').isString().isLength({ min: 10 }),
  body('vehicleBodyType').isIn(['open', 'box']),
  body('receiverIsSelf').optional().isBoolean(),
  body('remarks').optional().isString(),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      const list = errors.array();
      const error = list.map((e) => e.msg).join('. ') || 'Invalid booking data';
      return res.status(400).json({ error, errors: list });
    }
    const {
      transportCode,
      pickupAddress,
      dropoffAddress,
      senderName,
      senderPhone,
      receiverName,
      receiverPhone,
      vehicleBodyType,
      receiverIsSelf = false,
      remarks = null,
    } = req.body;

    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const booking = await client.query(
        `INSERT INTO bookings (
          user_id, transport_code, pickup_address, dropoff_address,
          sender_name, sender_phone, receiver_name, receiver_phone,
          receiver_is_self, vehicle_body_type, remarks
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
        RETURNING id, status, created_at`,
        [
          req.user.userId,
          transportCode,
          pickupAddress,
          dropoffAddress,
          senderName,
          senderPhone,
          receiverName,
          receiverPhone,
          receiverIsSelf,
          vehicleBodyType,
          remarks,
        ]
      );

      for (const [label, address] of [
        ['Pickup', pickupAddress],
        ['Drop-off', dropoffAddress],
      ]) {
        await client.query(
          `INSERT INTO recent_locations (user_id, label, address) VALUES ($1, $2, $3)`,
          [req.user.userId, label, address]
        );
      }

      await client.query('COMMIT');
      res.status(201).json(booking.rows[0]);
    } catch (e) {
      await client.query('ROLLBACK');
      if (e.code === '23503') {
        return res.status(400).json({ error: 'Invalid transport type' });
      }
      throw e;
    } finally {
      client.release();
    }
  }
);

router.get('/', authRequired, async (req, res) => {
  const { rows } = await pool.query(
    `SELECT b.id, b.transport_code, b.pickup_address, b.dropoff_address,
            b.status, b.created_at, t.label AS transport_label
     FROM bookings b
     JOIN transport_types t ON t.code = b.transport_code
     WHERE b.user_id = $1
     ORDER BY b.created_at DESC LIMIT 20`,
    [req.user.userId]
  );
  res.json(rows);
});

module.exports = router;
