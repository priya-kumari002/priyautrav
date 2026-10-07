const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { pool } = require('../db');

const router = express.Router();

function normalizePhone(countryCode, phone) {
  const digits = phone.replace(/\D/g, '');
  const cc = countryCode.replace(/\D/g, '') || '91';
  return `+${cc}${digits}`;
}

router.post(
  '/send-otp',
  body('phone').isLength({ min: 10, max: 15 }),
  body('countryCode').optional().isString(),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    const phone = normalizePhone(req.body.countryCode || '+91', req.body.phone);
    const otp = String(Math.floor(1000 + Math.random() * 9000));
    const otpHash = await bcrypt.hash(otp, 10);
    const expiresAt = new Date(Date.now() + (Number(process.env.OTP_EXPIRY_MINUTES) || 10) * 60 * 1000);

    await pool.query(
      `INSERT INTO otp_sessions (phone, otp_hash, expires_at) VALUES ($1, $2, $3)`,
      [phone, otpHash, expiresAt]
    );

    console.log(`[OTP] ${phone} => ${otp}`);

    const payload = {
      message: 'OTP sent successfully',
      phone,
      expiresInMinutes: Number(process.env.OTP_EXPIRY_MINUTES) || 10,
    };
    if (process.env.NODE_ENV === 'development') {
      payload.devOtp = otp;
    }
    res.json(payload);
  }
);

router.post(
  '/verify-otp',
  body('phone').isLength({ min: 10, max: 15 }),
  body('otp').isLength({ min: 4, max: 6 }),
  body('countryCode').optional().isString(),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    const phone = normalizePhone(req.body.countryCode || '+91', req.body.phone);
    const { otp } = req.body;

    const { rows } = await pool.query(
      `SELECT id, otp_hash, expires_at FROM otp_sessions
       WHERE phone = $1 AND verified = FALSE
       ORDER BY created_at DESC LIMIT 1`,
      [phone]
    );
    if (!rows.length) {
      return res.status(400).json({ error: 'No OTP session found. Request a new code.' });
    }
    const session = rows[0];
    if (new Date(session.expires_at) < new Date()) {
      return res.status(400).json({ error: 'OTP expired' });
    }
    const valid = await bcrypt.compare(otp, session.otp_hash);
    if (!valid) {
      return res.status(400).json({ error: 'Invalid OTP' });
    }

    await pool.query(`UPDATE otp_sessions SET verified = TRUE WHERE id = $1`, [session.id]);

    let userResult = await pool.query(`SELECT id, phone, name FROM users WHERE phone = $1`, [phone]);
    if (!userResult.rows.length) {
      userResult = await pool.query(
        `INSERT INTO users (phone) VALUES ($1) RETURNING id, phone, name`,
        [phone]
      );
    }
    const user = userResult.rows[0];
    const token = jwt.sign({ userId: user.id, phone: user.phone }, process.env.JWT_SECRET, {
      expiresIn: '7d',
    });

    res.json({
      token,
      user: { id: user.id, phone: user.phone, name: user.name },
    });
  }
);

module.exports = router;
