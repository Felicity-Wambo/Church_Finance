const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();

// Middleware
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use(
  '/api/v1/auth',
  require('./routes/authRoutes')
);

app.use(
  '/api/v1/dashboard',
  require('./routes/dashboardRoutes')
);

app.use(
  '/api/v1/giving',
  require('./routes/givingRoutes')
);

app.use(
  '/api/v1/giving-accounts',
  require('./routes/givingAccountRoutes')
);

app.use(
  '/api/v1/pledge',
  require('./routes/pledgeRoutes')
);

app.use(
  '/api/v1/churches',
  require('./routes/churchRoutes')
);

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Church Finance API is running',
    timestamp: new Date().toISOString(),
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route not found: ${req.method} ${req.originalUrl}`,
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err.stack);
  res.status(500).json({
    success: false,
    message: 'Something went wrong!',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

module.exports = app;