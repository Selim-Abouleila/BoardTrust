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
  const { id_jeu, date_retour_prevue } = req.body;

  // Check if the user is logged in first.
  if (!req.session.userId) {
    return res.status(401).json({ error: 'User not logged in' });
  }
  
  // Then check that all required parameters are provided.
  if (!id_jeu || !date_retour_prevue) {
    return res.status(400).json({ error: 'Missing parameters: id_jeu and/or date_retour_prevue' });
  }

  const sql = 'CALL LouerJeu(?, ?, ?)';
  db.query(sql, [req.session.userId, id_jeu, date_retour_prevue], (err, result) => {
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

  // Check if the user is logged in.
  if (!req.session.userId) {
    return res.status(401).json({ error: 'User not logged in' });
  }

  // Extract the required parameter (id_jeu).
  const { id_jeu } = req.body;
  if (!id_jeu) {
    return res.status(400).json({ error: 'Missing parameter: id_jeu' });
  }

  const sql = 'CALL RetournerJeu(?, ?)';
  
  // Use the session user ID and the provided id_jeu.
  db.query(sql, [req.session.userId, id_jeu], (err, result) => {
    if (err) {
      console.error('Return SQL Error:', err);
      return res.status(500).json({ error: 'Error while returning game' });
    }

    // The affected rows are usually available in result[1]. Check and act accordingly.
    const affectedRows = (result && result[1] && result[1].affectedRows) || 0;
    if (affectedRows === 0) {
      // This means no record was updated; the game might not be currently rented by the user.
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

app.post('/isRented', (req, res) => {
  const { id_utilisateur, id_jeu } = req.body;

  if (!id_utilisateur || !id_jeu) {
    return res.status(400).json({ error: 'Missing id_utilisateur or id_jeu' });
  }

  // First call the stored procedure
  const callProcedureSQL = 'CALL EstLoueParUtilisateur(?, ?, @isRented)';
  db.query(callProcedureSQL, [id_utilisateur, id_jeu], (err, results) => {
    if (err) {
      console.error('SQL Error in procedure call:', err);
      return res.status(500).json({ error: 'Error calling procedure' });
    }

    // Now get the value of the output variable
    const getOutputSQL = 'SELECT @isRented AS rented';
    db.query(getOutputSQL, (error, result2) => {
      if (error) {
        console.error('SQL Error in output retrieval:', error);
        return res.status(500).json({ error: 'Error retrieving rental status' });
      }

      // MySQL returns 1 for true.
      const rented = (result2[0].rented === 1);
      res.json({ rented });
    });
  });
});



// Start server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});