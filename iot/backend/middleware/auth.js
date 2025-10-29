/**
 * Middleware to verify API key
 */
function verifyApiKey(req, res, next) {
  const apiKey = req.headers["x-api-key"];

  if (!apiKey) {
    return res.status(401).json({
      success: false,
      error: "API key is required",
    });
  }

  if (apiKey !== process.env.API_KEY) {
    return res.status(403).json({
      success: false,
      error: "Invalid API key",
    });
  }

  next();
}

/**
 * Middleware to verify device credentials
 */
function verifyDevice(req, res, next) {
  const deviceId = req.headers["x-device-id"];
  const deviceSecret = req.headers["x-device-secret"];

  if (!deviceId || !deviceSecret) {
    return res.status(401).json({
      success: false,
      error: "Device credentials are required",
    });
  }

  if (
    deviceId !== process.env.DEVICE_ID ||
    deviceSecret !== process.env.DEVICE_SECRET
  ) {
    return res.status(403).json({
      success: false,
      error: "Invalid device credentials",
    });
  }

  // Attach device info to request
  req.device = {
    id: deviceId,
  };

  next();
}

/**
 * Error handler middleware
 */
function errorHandler(err, req, res, next) {
  console.error("Error:", err);

  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal server error";

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  });
}

/**
 * Not found handler
 */
function notFoundHandler(req, res) {
  res.status(404).json({
    success: false,
    error: "Route not found",
  });
}

module.exports = {
  verifyApiKey,
  verifyDevice,
  errorHandler,
  notFoundHandler,
};
