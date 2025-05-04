// database.js
const mysql = require('mysql2');
require('dotenv').config();

// Create a MySQL pool (auto-reconnects on dropped sockets)
const pool = mysql.createPool({
  host            : process.env.DB_HOST,
  port            : process.env.DB_PORT,
  user            : process.env.DB_USER,
  password        : process.env.DB_PASSWORD,
  database        : process.env.DB_NAME,
  waitForConnections : true,
  connectionLimit    : 10,
  queueLimit         : 0
});

// Optional: expose promise-based pool if you prefer async/await
// const promisePool = pool.promise();
// module.exports = promisePool;

// Or export the callback-style pool directly:
module.exports = pool;
