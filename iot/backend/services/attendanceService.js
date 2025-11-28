const { db, Timestamp } = require("../config/firebase");

/**
 * Get active schedule for today
 * @returns {Promise<Object|null>} Schedule data or null
 */
async function getTodaySchedule() {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const jadwalRef = db.collection("jadwal");
    const snapshot = await jadwalRef
      .where("isAktif", "==", true)
      .where("tanggal", ">=", Timestamp.fromDate(today))
      .where("tanggal", "<", Timestamp.fromDate(tomorrow))
      .limit(1)
      .get();

    if (snapshot.empty) {
      return null;
    }

    const doc = snapshot.docs[0];
    const data = doc.data();
    const scheduleTime = checkScheduleTime(data.waktuMulai, data.waktuSelesai);
    console.log("Today's schedule found:", { id: doc.id, ...data, ...scheduleTime });
    return {
      id: doc.id,
      ...data,
      ...scheduleTime,
    };
  } catch (error) {
    console.error("Error getting today's schedule:", error);
    return null;
  }
}

/**
 * Check if user already has attendance today
 * @param {string} userId - User ID
 * @returns {Promise<Object|null>} Attendance data or null
 */
async function getTodayAttendance(jadwalId, userId) {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const presensiRef = db.collection("presensi");
    const snapshot = await presensiRef
      .where("userId", "==", userId)
      .where("activity", "==", jadwalId)
      .limit(1)
      .get();
    console.log("userId:", userId, "jadwalId:", jadwalId);
    if (snapshot.empty) {
      return null;
    }

    const doc = snapshot.docs[0];
    return {
      id: doc.id,
      ...doc.data(),
    };
  } catch (error) {
    throw new Error(`Error getting today's attendance: ${error.message}`);
  }
}

/**
 * Check if current time is within schedule time
 * @param {string} waktuMulai - Start time (HH:mm format)
 * @param {string} waktuSelesai - End time (HH:mm format)
 * @returns {Object} { isWithinSchedule: boolean, status: string }
 */
function checkScheduleTime(waktuMulai, waktuSelesai) {
  try {
    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    const currentTime = currentHour * 60 + currentMinute;

    const [startHour, startMinute] = waktuMulai.split(":").map(Number);
    const startTime = startHour * 60 + startMinute;

    const [endHour, endMinute] = waktuSelesai.split(":").map(Number);
    const endTime = endHour * 60 + endMinute;

    if (currentTime < startTime) {
      return {
        isWithinSchedule: false,
        status: "too_early",
        message: `Presensi belum dibuka. Waktu mulai: ${waktuMulai}`,
      };
    }

    if (currentTime > endTime) {
      return {
        isWithinSchedule: false,
        status: "too_late",
        message: `Waktu presensi sudah berakhir. Waktu selesai: ${waktuSelesai}`,
      };
    }

    return {
      isWithinSchedule: true,
      status: "on_time",
      message: "Dalam waktu presensi",
    };
  } catch (error) {
    console.error("Error checking schedule time:", error);
    return {
      isWithinSchedule: true,
      status: "unknown",
      message: "Tidak dapat memeriksa waktu jadwal",
    };
  }
}

/**
 * Create attendance record
 * @param {Object} attendanceData - Attendance data
 * @returns {Promise<Object>} Created attendance record
 */
async function createAttendance(attendanceData) {
  try {
    const presensiRef = db.collection("presensi");
    const docRef = await presensiRef.add({
      ...attendanceData,
      timestamp: Timestamp.now(),
      status: "hadir",
    });

    const doc = await docRef.get();
    return {
      id: doc.id,
      ...doc.data(),
    };
  } catch (error) {
    throw new Error(`Error creating attendance: ${error.message}`);
  }
}

/**
 * Log device activity
 * @param {Object} logData - Log data
 * @returns {Promise<void>}
 */
async function logDeviceActivity(logData) {
  try {
    const logsRef = db.collection("device_logs");
    await logsRef.add({
      ...logData,
      timestamp: Timestamp.now(),
    });
  } catch (error) {
    console.error("Error logging device activity:", error);
  }
}

/**
 * Get attendance statistics for user
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Attendance statistics
 */
async function getAttendanceStats(userId) {
  try {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const presensiRef = db.collection("presensi");
    const snapshot = await presensiRef
      .where("userId", "==", userId)
      .where("timestamp", ">=", Timestamp.fromDate(startOfMonth))
      .get();

    const stats = {
      total: snapshot.size,
      hadir: 0,
      izin: 0,
      sakit: 0,
      alpha: 0,
    };

    snapshot.forEach((doc) => {
      const data = doc.data();
      if (stats.hasOwnProperty(data.status)) {
        stats[data.status]++;
      }
    });

    return stats;
  } catch (error) {
    throw new Error(`Error getting attendance stats: ${error.message}`);
  }
}
async function createLogActivity(data) {
  try {
    const logsRef = db.collection("activities");
    await logsRef.add({
      ...data,
      timestamp: Timestamp.now(),
    });
    console.log("Activity logged successfully");
  } catch (error) {
    console.error("Error logging activity:", error);
  }
}

module.exports = {
  getTodaySchedule,
  getTodayAttendance,
  checkScheduleTime,
  createAttendance,
  logDeviceActivity,
  getAttendanceStats,
  createLogActivity,
};
