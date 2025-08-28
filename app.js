const express = require("express");
const bcrypt = require("bcrypt");
const db = require("./db"); // MySQL connection
const app = express();

// ----- Middlewares -----
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// ----- Root -----
app.get("/", (req, res) => {
  res.send("Expense Tracker API running");
});

// ----- Generate Password Hash (optional) -----
app.get("/hash/:text", async (req, res) => {
  try {
    const raw = req.params.text;
    const hashed = await bcrypt.hash(raw, 10);
    res.send(hashed);
  } catch (err) {
    res.status(500).send("Error hashing text");
  }
});

// ----- Login -----
app.post("/login", (req, res) => {
  const { username, password } = req.body;
  const sql = "SELECT id, password FROM users WHERE username = ?";

  db.query(sql, [username], (err, rows) => {
    if (err) return res.status(500).json({ error: "DB query error" });
    if (rows.length !== 1) return res.status(401).json({ error: "Invalid user" });

    bcrypt.compare(password, rows[0].password, (cmpErr, match) => {
      if (cmpErr) return res.status(500).json({ error: "Password check error" });
      if (match) {
        return res.json({ id: rows[0].id, message: "Login success" });
      } else {
        return res.status(401).json({ error: "Wrong password" });
      }
    });
  });
});

// ----- Register -----
app.post("/register", (req, res) => {
  const { username, password } = req.body;
  const check = "SELECT id FROM users WHERE username = ?";

  db.query(check, [username], (err, rows) => {
    if (err) return res.status(500).send("DB error");
    if (rows.length > 0) return res.status(409).send("User already exists");

    bcrypt.hash(password, 10, (hashErr, hash) => {
      if (hashErr) return res.status(500).send("Hash error");

      const insert = "INSERT INTO users (username, password) VALUES (?, ?)";
      db.query(insert, [username, hash], (insErr) => {
        if (insErr) return res.status(500).send("Insert failed");
        res.status(201).send("User created");
      });
    });
  });
});

// ----- Get Expenses -----
app.get("/expenses", (req, res) => {
  const { userId, date, keyword } = req.query;
  let sql = "SELECT * FROM expense WHERE user_id = ?";
  const params = [userId];

  if (date) {
    sql += " AND DATE(date) = ?";
    params.push(date);
  }
  if (keyword) {
    sql += " AND item LIKE ?";
    params.push("%" + keyword + "%");
  }

  db.query(sql, params, (err, rows) => {
    if (err) return res.status(500).send("DB error");
    res.json(rows);
  });
});

// ----- Add Expense -----
app.post("/expenses", (req, res) => {
  const { userId, item, paid } = req.body;
  const sql = "INSERT INTO expense (user_id, item, paid, date) VALUES (?, ?, ?, NOW())";
  const params = [userId, item, paid];

  db.query(sql, params, (err) => {
    if (err) return res.status(500).send("Insert failed");
    res.status(201).send("Expense inserted");
  });
});

// ----- Delete Expense -----
app.delete("/expenses/:id", (req, res) => {
  const { id } = req.params;
  const { userId } = req.query;
  const sql = "DELETE FROM expense WHERE id = ? AND user_id = ?";

  db.query(sql, [id, userId], (err, result) => {
    if (err) return res.status(500).send("Delete error");
    if (result.affectedRows === 0) {
      return res.status(404).send("Expense not found for this user");
    }
    res.status(200).send("Expense removed");
  });
});

// ----- Start Server -----
const PORT = 3000;
app.listen(PORT, () => {
  console.log("API running at http://localhost:" + PORT);
});
