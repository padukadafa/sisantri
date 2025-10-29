const { db, Timestamp } = require("../config/firebase");

/**
 * Find user by RFID
 * @param {string} rfidUid - RFID UID
 * @returns {Promise<Object|null>} User data or null
 */
async function findUserByRFID(rfidUid) {
  try {
    const usersRef = db.collection("users");
    const snapshot = await usersRef
      .where("rfidCardId", "==", rfidUid)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return null;
    }

    const doc = snapshot.docs[0];
    return {
      id: doc.id,
      ...doc.data(),
    };
  } catch (error) {
    throw new Error(`Error finding user by RFID: ${error.message}`);
  }
}

module.exports = {
  findUserByRFID,
};
