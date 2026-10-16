// Local development server: node backend/server.js  ->  http://localhost:8000
const app = require('./app');
const PORT = process.env.PORT || 8000;
app.listen(PORT, () => console.log('JanSahay running at http://localhost:' + PORT));
