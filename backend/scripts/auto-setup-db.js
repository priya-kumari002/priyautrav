/**
 * Creates shifter DB/user using postgres superuser.
 * Usage: set PGPASSWORD=your_postgres_password && node scripts/auto-setup-db.js
 * Or:    node scripts/auto-setup-db.js YourPostgresPassword
 */
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const adminPassword = process.argv[2] || process.env.PGPASSWORD || process.env.POSTGRES_PASSWORD;

async function tryAdmin(pw) {
  const c = new Client({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: pw,
    database: 'postgres',
  });
  await c.connect();
  return c;
}

async function main() {
  let client;
  const tries = adminPassword ? [adminPassword] : ['postgres', 'admin', '123456', 'password', 'root', ''];
  for (const pw of tries) {
    try {
      client = await tryAdmin(pw);
      console.log('Connected as postgres.');
      break;
    } catch {
      /* next */
    }
  }
  if (!client) {
    console.error(
      'Could not connect as postgres. Run:\n' +
        '  cd D:\\priyautrav\\backend\n' +
        '  node scripts/auto-setup-db.js YOUR_POSTGRES_PASSWORD'
    );
    process.exit(1);
  }

  await client.query(`
    DO $$ BEGIN
      CREATE USER shifter WITH PASSWORD 'shifter123';
    EXCEPTION WHEN duplicate_object THEN NULL;
    END $$;
  `);
  const db = await client.query(`SELECT 1 FROM pg_database WHERE datname = 'shifter'`);
  if (!db.rows.length) {
    await client.query(`CREATE DATABASE shifter OWNER shifter`);
  }
  await client.query(`GRANT ALL PRIVILEGES ON DATABASE shifter TO shifter`);
  await client.end();

  const app = new Client({ connectionString: process.env.DATABASE_URL });
  await app.connect();
  const sql = fs.readFileSync(path.join(__dirname, '..', 'src', 'migrations', '001_init.sql'), 'utf8');
  await app.query(sql);
  await app.end();
  console.log('Database shifter ready. Migrations applied.');
}

main().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
