process.env.FIRESTORE_ENABLE_TELEMETRY = "false";
process.env.GOOGLE_CLOUD_ENABLE_TELEMETRY = "false";

const admin = require("firebase-admin");
require("dotenv").config();

// Initialize Firebase Admin
const serviceAccount = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
db.settings({ preferRest: true });

const FieldValue = admin.firestore.FieldValue;
const Timestamp = admin.firestore.Timestamp;

module.exports = { admin, db, FieldValue, Timestamp };
