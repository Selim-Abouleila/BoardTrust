const express = require('express');
const db = require('./database'); // 👈 Import the DB connection
const path = require('path'); // 👈 Add the 'path' import


require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
// Serve static files from the "frontend" folder
app.use(express.static(path.join(__dirname, '../frontend')));

// Serve the index.html when visiting the root
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend', 'main.html'));  // Serve the index page
});

// RENT GAME
app.post('/rent', (req, res) => {
  const { id_utilisateur, id_jeu, date_retour_prevue } = req.body;

  if (!id_utilisateur || !id_jeu || !date_retour_prevue) {
    return res.status(400).json({ error: 'Missing parameters' });
  }

  const sql = 'CALL LouerJeu(?, ?, ?)';
  db.query(sql, [id_utilisateur, id_jeu, date_retour_prevue], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Error while renting game' });
    }

    res.json({ message: 'Game rented successfully' });
  });
});

// GET location history
app.get('/history', (req, res) => {
  const sql = 'SELECT * FROM VueHistoriqueLocation';

  db.query(sql, (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Error fetching history' });
    }

    res.json(results);
  });
});

// RETURN GAME
app.post('/return', (req, res) => {
  const { id_jeu } = req.body;

  if (!id_jeu) {
    return res.status(400).json({ error: 'Missing id_jeu' });
  }

  const sql = 'CALL RetournerJeu(?)';
  db.query(sql, [id_jeu], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Error while returning game' });
    }

    res.json({ message: 'Game returned successfully' });
  });
});

// GET list of games
app.get('/games', (req, res) => {
  const sql = 'SELECT * FROM Jeu';

  db.query(sql, (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Error fetching games' });
    }

    res.json(results);
  });
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});


// User Registration (without bcrypt)
app.post('/register', (req, res) => {
  const { pseudo, email, mot_de_passe } = req.body;

  // Do not hash the password, store it as plain text
  const sql = 'CALL AddUser(?, ?, ?)';
  db.query(sql, [pseudo, email, mot_de_passe], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Error registering user' });
    }

    res.json({ message: 'User registered successfully' });
  });
});

// Login route
app.post('/login', (req, res) => {
  console.log('Request body:', req.body);
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const sql = 'SELECT * FROM Utilisateur WHERE email = ?';
  db.query(sql, [email], (err, results) => {
    if (err) {
      console.error('SQL Error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    console.log('Query results:', results);
    if (results.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = results[0];
    if (password !== user.mot_de_passe) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    req.session.userId = user.id_utilisateur;
    console.log('Session ID set:', req.session.userId);

    res.json({ message: 'Login successful', user: { id_utilisateur: user.id_utilisateur, pseudo: user.pseudo } });
  });
});