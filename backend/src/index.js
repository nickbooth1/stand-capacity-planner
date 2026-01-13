const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3002;

// Database connection pool
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'stand_capacity',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,
}));
app.use(express.json());

// Health check endpoint
app.get('/api/health', async (req, res) => {
  let dbStatus = 'disconnected';

  try {
    const result = await pool.query('SELECT NOW()');
    dbStatus = 'connected';
  } catch (err) {
    console.error('Database connection error:', err.message);
    dbStatus = 'error: ' + err.message;
  }

  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    database: dbStatus,
  });
});

// API routes
app.get('/api', (req, res) => {
  res.json({
    message: 'Stand Capacity Planner API',
    version: '0.1.0',
    endpoints: {
      health: '/api/health',
      stands: '/api/stands',
      capacity: '/api/capacity',
    },
  });
});

// Placeholder routes - to be implemented
app.get('/api/stands', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM stands ORDER BY stand_id');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/capacity', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM capacity_plans ORDER BY id');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`Backend API server running on http://0.0.0.0:${port}`);
});

module.exports = { app, pool };
