// database.js
const mysql = require('mysql2');
require('dotenv').config();

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

// Now export exactly the same interface your routes expect:
module.exports = {
  query: (...args) => pool.query(...args),
  // if you ever need to get a raw connection:
  getConnection: (...args) => pool.getConnection(...args),
};
