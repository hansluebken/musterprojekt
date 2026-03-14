const express = require('express');

const app = express();
const PORT = process.env.PORT || 3333;

app.get('/', (req, res) => {
  res.json({
    name: 'Musterprojekt',
    status: 'running',
    environment: process.env.NODE_ENV || 'development',
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Server laeuft auf Port ${PORT}`);
});
