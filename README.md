**BoardTrust**

BoardTrust is a full-stack board game rental platform with a Node.js/Express/MySQL backend and a vanilla JavaScript/HTML/CSS frontend.

---

*Features*

* Browse and rent board games with a return date picker.
* Leave comments and view them
* Return games you have rented.
* View your rental history in a sortable table.
* User authentication with signup, login, and logout using sessions.
* Responsive, mobile-friendly interface.

---

*Live Demo*

The live version is available at:
https://boardtrust-production.up.railway.app/

You can also run the application locally by following the instructions below.

---

*Tech Stack*

* **Backend**: Node.js, Express.js, MySQL (stored procedures: `LouerJeu`, `RetournerJeu`, `ViewHistory`, `ViewRentedGames`)
* **Frontend**: Vanilla JavaScript, HTML5, CSS3
* **Session Management**: express-session, CORS
* **Deployment**: Railway.app with connection pooling to handle auto-sleep

---

*Getting Started*

*Prerequisites*

* Node.js v14 or later
* MySQL server
* Git

*Installation*

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/boardtrust.git
   cd boardtrust/backend
   ```
2. **Install dependencies**

   ```bash
   npm install
   ```
3. **Configure environment variables**
   Copy `.env.example` to `.env` and update with your credentials:

   ```ini
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=your_password
   DB_NAME=boardtrust
   ```
4. **Initialize the database**

   ```sql
   CREATE DATABASE boardtrust;
   USE boardtrust;
   -- Run schema and procedure scripts
   ```

---

*Running the Application*

Backend

In the `backend` folder, run:

```bash
npm start
```

The API will be available on port 3000.

Frontend

Open `frontend/main.html` in your browser or serve it via Express’s static middleware.

---

*API Endpoints*

* `POST /register` — register a new user
* `POST /login` — authenticate and start session
* `GET /games` — list available games
* `POST /rent` — rent a game
* `POST /return` — return a game
* `POST /history` — view rental history
* `POST /rentedGames` — view current rentals
* `POST /logout` — end session

---

*Project Structure*

```
boardtrust/
├ backend/              # API server
│ ├ database.js         # MySQL pool configuration
│ ├ index.js            # Express routes
│ └ ...
└ frontend/             # Static site
  ├ main.html
  ├ rent.html
  ├ retour.html
  ├ history.html
  ├ login.html
  ├ register.html
  └ assets/             # images, logo, banner
```

---

