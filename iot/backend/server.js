const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
const rateLimit = require("express-rate-limit");
require("dotenv").config();

const attendanceRoutes = require("./routes/attendance");
const {
  verifyApiKey,
  errorHandler,
  notFoundHandler,
} = require("./middleware/auth");

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());

// CORS configuration
app.use(
  cors({
    origin: process.env.ALLOWED_ORIGINS?.split(",") || "*",
    methods: ["GET", "POST"],
    allowedHeaders: [
      "Content-Type",
      "x-api-key",
      "x-device-id",
      "x-device-secret",
    ],
  })
);

// Request logging
app.use(morgan("combined"));

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "SiSantri IoT Backend is running",
    timestamp: new Date().toISOString(),
    version: "1.0.0",
  });
});

app.use("/api/attendance", verifyApiKey, attendanceRoutes);

app.use(notFoundHandler);

app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════╗
║   SiSantri IoT Backend Server Started     ║
╠════════════════════════════════════════════╣
║   Environment: ${process.env.NODE_ENV || "development"}                   ║
║   Port: ${PORT}                              ║
║   Time: ${new Date().toLocaleString()}      ║
╚════════════════════════════════════════════╝
  `);
});

process.on("SIGTERM", () => {
  console.log("SIGTERM signal received: closing HTTP server");
  process.exit(0);
});

process.on("SIGINT", () => {
  console.log("SIGINT signal received: closing HTTP server");
  process.exit(0);
});

module.exports = app;
