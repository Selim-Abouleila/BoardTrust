/**************************************************************************
 *  index.js  –  BoardTrust API & static hosting
 **************************************************************************/
const express = require('express');
const db      = require('./database');
const path    = require('path');
const session = require('express-session');
const cors    = require('cors');
require('dotenv').config();

const app  = express();
const port = process.env.PORT || 3000;

/*─────────────────────────────────────────────────────────────────────────
│  MIDDLEWARE
└────────────────────────────────────────────────────────────────────────*/
app.use(express.json());

/*  Allow the two front-end origins and **always** send cookies */
app.use(cors({
  origin: ['https://boardtrust-production.up.railway.app', 'http://localhost:3000'],
  credentials: true
}));

/*  Static build of the front-end  */
app.use(express.static(path.join(__dirname, '../frontend')));

app.set('trust proxy', 1);   // needed when you run behind Railway’s proxy

/*  Session cookie  */
app.use(session({
  secret            : process.env.SESSION_SECRET || 'change-this-secret',
  resave            : false,
  saveUninitialized : false,
  cookie: {
    httpOnly : true,
    sameSite : 'lax',
    secure   : process.env.NODE_ENV === 'production'
  }
}));

/*─────────────────────────────────────────────────────────────────────────
│  DATABASE CONNECTIVITY (one early check)
└────────────────────────────────────────────────────────────────────────*/
db.connect(err => {
  if (err) {
    console.error('❌ Database connection error:', err);
    process.exit(1);
  }
  console.log('✅ Connected to database');
});

/*─────────────────────────────────────────────────────────────────────────
│  ROUTES
└────────────────────────────────────────────────────────────────────────*/

/* Quick health-check */
app.get('/test', (_, res) => res.json({ message: 'Backend is running' }));

/* Serve the SPA entry point */
app.get('/', (_, res) => {
  res.sendFile(path.join(__dirname, '../frontend', 'main.html'));
});

/*──── AUTH ─────────────────────────────────────────────────────────────*/

app.post('/register', (req, res) => {
  const { pseudo, email, password } = req.body;
  if (!pseudo || !email || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  db.query('CALL AddUser(?, ?, ?)', [pseudo, email, password], err => {
    if (err) {
      console.error('Register SQL Error:', err);
      return res.status(500).json({ error: 'Error registering user' });
    }
    res.json({ message: 'User registered successfully' });
  });
});

app.post('/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  db.query('SELECT * FROM Utilisateur WHERE email = ?', [email], (err, results) => {
    if (err)        return res.status(500).json({ error: 'Database error' });
    if (results.length === 0)               return res.status(401).json({ error: 'Invalid email or password' });

    const user = results[0];
    if (password !== user.mot_de_passe)     return res.status(401).json({ error: 'Invalid email or password' });

    req.session.userId = user.id_utilisateur;
    res.json({
      message : 'Login successful',
      user    : { id_utilisateur: user.id_utilisateur, pseudo: user.pseudo }
    });
  });
});

/* Returns who is authenticated right now (helps the front-end) */
app.get('/me', (req, res) => {
  if (!req.session.userId) return res.json({ loggedIn: false });
  res.json({ loggedIn: true, id_utilisateur: req.session.userId });
});

/*──── GAME ACTIONS ─────────────────────────────────────────────────────*/

app.post('/rent', (req, res) => {
  const { id_jeu, date_retour_prevue } = req.body;
  if (!req.session.userId)          return res.status(401).json({ error: 'User not logged in' });
  if (!id_jeu || !date_retour_prevue) return res.status(400).json({ error: 'Missing parameters' });

  db.query('CALL LouerJeu(?, ?, ?)', [req.session.userId, id_jeu, date_retour_prevue], err => {
    if (err)  return res.status(500).json({ error: 'Error while renting game' });
    res.json({ message: 'Game rented successfully' });
  });
});

app.post('/return', (req, res) => {
  const { id_jeu } = req.body;
  if (!req.session.userId)  return res.status(401).json({ error: 'User not logged in' });
  if (!id_jeu)              return res.status(400).json({ error: 'Missing parameter: id_jeu' });

  db.query('CALL RetournerJeu(?, ?)', [req.session.userId, id_jeu], (err, result) => {
    if (err) return res.status(500).json({ error: 'Error while returning game' });

    const affectedRows = result?.[1]?.affectedRows || 0;
    if (!affectedRows) return res.status(400).json({ error: 'Game is not currently being rented.' });

    res.json({ message: 'Game returned successfully' });
  });
});

/*──── READ-ONLY HELPERS ────────────────────────────────────────────────*/

app.get('/games', (_, res) => {
  db.query('SELECT * FROM VueJeuSansDescription', (err, results) => {
    if (err) return res.status(500).json({ error: 'Error fetching games' });
    res.json(results);
  });
});

app.post('/isRented', (req, res) => {
  const { id_utilisateur, id_jeu } = req.body;
  if (!id_utilisateur || !id_jeu)          return res.status(400).json({ error: 'Missing id_utilisateur or id_jeu' });

  db.query('CALL EstLoueParUtilisateur(?, ?, @isRented)', [id_utilisateur, id_jeu], err => {
    if (err) return res.status(500).json({ error: 'Error calling procedure' });

    db.query('SELECT @isRented AS rented', (error, rows) => {
      if (error)  return res.status(500).json({ error: 'Error retrieving rental status' });
      res.json({ rented: rows[0].rented === 1 });
    });
  });
});


/* Logout endpoint */
app.post('/logout', (req, res) => {
  console.log('Logout request received, session:', req.session);

  if (!req.session.userId) {
    console.log('Logout attempt: User not logged in');
    return res.status(401).json({ error: 'Must log in first before disconnecting' });
  }

  console.log('Logging out user with ID:', req.session.userId);
  req.session.destroy(err => {
    if (err) {
      console.error('Logout error:', err);
      return res.status(500).json({ error: 'Failed to log out' });
    }
    console.log('User logged out successfully');
    res.json({ message: 'Logged out successfully' });
  });
});

/* Check if user is logged in */
app.get('/isLoggedIn', (req, res) => {
  console.log('isLoggedIn request received, session:', req.session);

  if (!req.session.userId) {
    console.log('User not logged in');
    return res.json({ loggedIn: false });
  }

  console.log('User is logged in, ID:', req.session.userId);
  res.json({ loggedIn: true, id_utilisateur: req.session.userId });
});

/* Get location history for the logged-in user */
// --- just after your other routes in index.js ---

/*─── HISTORIQUE ────────────────────────────────────────────────*/
app.get('/api/history', (req, res) => {
  console.log('History request received, session:', req.session);

  const userId = req.session.userId;
  if (!userId) {
    console.log('History request: User not logged in');
    return res.status(401).json({ error: 'User not logged in' });
  }

  console.log('Fetching history for user ID:', userId);
  db.query('CALL ViewHistory(?)', [userId], (err, results) => {
    if (err) {
      console.error('History SQL Error:', err);
      return res.status(500).json({ error: 'Error fetching history' });
    }

    // MySQL returns an array of result‐sets; the first one is our rows
    const rows = results[0] || [];

    // Map to cleaner keys if you like
    const history = rows.map(row => ({
      idLocation:               row.id_location,
      gameName:                 row.GameName  || row.nom,            // adjust to your column
      dateLocation:             row.DateLocation,
      dateRetourPrevue:         row.DateRetourPrevue,
      dateRetourEffective:      row.DateRetourEffective
    }));

    res.json(history);
  });
});


/*─────────────────────────────────────────────────────────────────────────
│  START SERVER
└────────────────────────────────────────────────────────────────────────*/
app.listen(port, () => console.log(`🚀  API listening on :${port}`));
