const app = require('./src/app');
const connectDB = require('./src/config/database');
const dotenv = require('dotenv');

dotenv.config();

connectDB();

const PORT = process.env.PORT || 5300;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📍 http://localhost:${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV}`);
  console.log(`📡 Health check: http://localhost:${PORT}/health`);
});