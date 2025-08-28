const mysql = require("mysql2"); // use mysql2 here

const db = mysql.createConnection({
  host: "localhost",
  user: "root",       // your MySQL username
  password: "",       // your MySQL password
  database: "expenses"
});

db.connect((err) => {
  if (err) throw err;
  console.log("MySQL connected!");
});

module.exports = db;
