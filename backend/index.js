const express = require('express');
const db = require('./database'); // 👈 Import the DB connection
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Test route
app.get('/', (req, res) => {
  res.send('Rental API is running!');
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});



//RENT GAME

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
