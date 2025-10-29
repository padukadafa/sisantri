const { db, Timestamp } = require("../config/firebase");
/**
 * Add user point
 * @param {string} rfidUid - RFID UID
 * @returns {Promise<Object|null>} Message or null
 */

const addUserPoint = async (user, points) => {
  try {
    const userRef = db.collection("users").doc(user.id);
    await userRef.update({
      poin: Number(user.poin) + Number(points),
      updatedAt: Timestamp.now(),
    });
    return { message: "User points updated successfully" };
  } catch (error) {
    console.error("Error updating user points:", error);
    return null;
  }
};

module.exports = {
  addUserPoint,
};
