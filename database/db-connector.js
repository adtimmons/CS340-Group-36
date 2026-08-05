const mysql = require("mysql2/promise");

const pool = mysql.createPool({
  host: "classmysql.engr.oregonstate.edu",
  user: "cs340_timmonal",
  password: "XXXX",
  database: "cs340_timmonal",
  connectionLimit: 10
});

module.exports = pool;