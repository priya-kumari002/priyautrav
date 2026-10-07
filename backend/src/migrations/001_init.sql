CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  phone VARCHAR(15) UNIQUE NOT NULL,
  name VARCHAR(120),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS otp_sessions (
  id SERIAL PRIMARY KEY,
  phone VARCHAR(15) NOT NULL,
  otp_hash VARCHAR(255) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_otp_phone ON otp_sessions (phone, created_at DESC);

CREATE TABLE IF NOT EXISTS transport_types (
  id SERIAL PRIMARY KEY,
  code VARCHAR(32) UNIQUE NOT NULL,
  label VARCHAR(64) NOT NULL,
  icon_key VARCHAR(32) NOT NULL
);

INSERT INTO transport_types (code, label, icon_key) VALUES
  ('two_wheeler', '2-Wheeler', 'two_wheeler'),
  ('mini_truck', 'Mini Truck', 'mini_truck'),
  ('three_wheeler', '3-Wheeler', 'three_wheeler'),
  ('big_truck', 'Big Truck', 'big_truck')
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS bookings (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  transport_code VARCHAR(32) NOT NULL REFERENCES transport_types(code),
  pickup_address TEXT NOT NULL,
  dropoff_address TEXT NOT NULL,
  sender_name VARCHAR(120) NOT NULL,
  sender_phone VARCHAR(15) NOT NULL,
  receiver_name VARCHAR(120) NOT NULL,
  receiver_phone VARCHAR(15) NOT NULL,
  receiver_is_self BOOLEAN DEFAULT FALSE,
  vehicle_body_type VARCHAR(16) NOT NULL CHECK (vehicle_body_type IN ('open', 'box')),
  remarks TEXT,
  status VARCHAR(32) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bookings_user ON bookings (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS recent_locations (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label VARCHAR(120) NOT NULL,
  address TEXT NOT NULL,
  used_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recent_user ON recent_locations (user_id, used_at DESC);
