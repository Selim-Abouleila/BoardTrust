const express = require('express');
const db = require('./database');
const path = require('path');
const session = require('express-session');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors({
  origin: ['https://boardtrust-production.up.railway.app', 'http://localhost:3000'],
  credentials: true
}));
app.use(express.static(path.join(__dirname, '../frontend')));
app.set('trust proxy', 1);

// Session configuration
app.use(session({
  secret: process.env.SESSION_SECRET || 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: process.env.NODE_ENV === 'production' }
}));

// Database connection check
db.connect((err) => {
  if (err) {
    console.error('Database connection error:', err);
    process.exit(1);
  }
  console.log('Connected to database');
});

// Test endpoint
app.get('/test', (req, res) => {
  res.json({ message: 'Backend is running' });
});

// Serve the index.html when visiting the root
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend', 'main.html'));
});

// User Registration
app.post('/register', (req, res) => {
  console.log('Register request body:', req.body);
  const { pseudo, email, password } = req.body;

  if (!pseudo || !email || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  const sql = 'CALL AddUser(?, ?, ?)';
  db.query(sql, [pseudo, email, password], (err, result) => {
    if (err) {
      console.error('Register SQL Error:', err);
      return res.status(500).json({ error: 'Error registering user' });
    }

    res.json({ message: 'User registered successfully' });
  });
});

// User Login
app.post('/login', (req, res) => {
  console.log('Login request body:', req.body);
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const sql = 'SELECT * FROM Utilisateur WHERE email = ?';
  db.query(sql, [email], (err, results) => {
    if (err) {
      console.error('Login SQL Error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    console.log('Login query results:', results);
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

// Rent Game
app.post('/rent', (req, res) => {
  console.log('Rent request body:', req.body);
  const { id_utilisateur, id_jeu, date_retour_prevue } = req.body;

  if (!id_utilisateur || !id_jeu || !date_retour_prevue) {
    return res.status(400).json({ error: 'Missing parameters' });
  }

  const sql = 'CALL LouerJeu(?, ?, ?)';
  db.query(sql, [id_utilisateur, id_jeu, date_retour_prevue], (err, result) => {
    if (err) {
      console.error('Rent SQL Error:', err);
      return res.status(500).json({ error: 'Error while renting game' });
    }

    res.json({ message: 'Game rented successfully' });
  });
});

// Get Location History
app.get('/history', (req, res) => {
  const sql = 'SELECT * FROM VueHistoriqueLocation';

  db.query(sql, (err, results) => {
    if (err) {
      console.error('History SQL Error:', err);
      return res.status(500).json({ error: 'Error fetching history' });
    }

    res.json(results);
  });
});

// Return Game
app.post('/return', (req, res) => {
  console.log('Return request body:', req.body);
  const { id_jeu, id_utilisateur } = req.body;

  if (!id_jeu || !id_utilisateur) {
    return res.status(400).json({ error: 'Missing id_jeu or id_utilisateur' });
  }

  const sql = 'CALL RetournerJeu(?, ?)';
  
  db.query(sql, [id_utilisateur, id_jeu], (err, result) => {
    if (err) {
      console.error('Return SQL Error:', err);
      return res.status(500).json({ error: 'Error while returning game' });
    }

    // Depending on your MySQL driver, the affected rows may be in a different position.
    // In many MySQL Node drivers when calling a procedure, the second element contains the OkPacket info.
    const affectedRows = (result && result[1] && result[1].affectedRows) || 0;

    if (affectedRows === 0) {
      // No rows updated means the game wasn't currently rented by this user.
      return res.status(400).json({ error: 'Game is not currently being rented.' });
    }

    res.json({ message: 'Game returned successfully' });
  });
});

// Get List of Games
app.get('/games', (req, res) => {
  const sql = 'SELECT * FROM Jeu';

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Games SQL Error:', err);
      return res.status(500).json({ error: 'Error fetching games' });
    }

    res.json(results);
  });
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});