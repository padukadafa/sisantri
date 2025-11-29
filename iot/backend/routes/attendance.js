const express = require("express");
const { body, validationResult } = require("express-validator");
const {
  getTodaySchedule,
  getTodayAttendance,
  checkScheduleTime,
  createAttendance,
  getAttendanceStats,
  createLogActivity,
} = require("../services/attendanceService");
const { verifyDevice } = require("../middleware/auth");
const { findUserByRFID } = require("../services/userService");
const { addUserPoint } = require("../services/gamifikasiService");
const router = express.Router();

/**
 * POST /api/attendance/scan
 * Record attendance from RFID scan
 */
router.post(
  "/scan",
  verifyDevice,
  [
    body("rfidUid").notEmpty().withMessage("RFID UID is required"),
    body("rfidUid").isString().withMessage("RFID UID must be a string"),
  ],
  async (req, res, next) => {
    // validasi input
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: "Validation error",
          details: errors.array(),
        });
      }

      // mendapatkan rfid
      const { rfidUid } = req.body;
      const deviceId = req.device.id;

      console.log(`RFID scan received: ${rfidUid} from device: ${deviceId}`);
      // mendapatkan jadwal hari ini
      const schedule = await getTodaySchedule();
      
      if (!schedule) {
        return res.status(403).json({
          success: false,
          message: "Tidak ada jadwal untuk hari ini",
        });
      }
      if (schedule.status === "too_early") {
        return res.status(403).json({
          success: false,
          message: schedule.message,
        });
      }
      if (schedule.status === "too_late") {
        return res.status(403).json({
          success: false,
          message: schedule.message,
        });
      }
      if (schedule.status === "unknown") {
        return res.status(403).json({
          success: false,
          message: schedule.message,
        });
      }
      if (!schedule.isAktif) {
        return res.status(403).json({
          success: false,
          message: schedule.message,
        });
      }

      // mencari user berdasarkan rfid
      const user = await findUserByRFID(rfidUid);
      if (!user) {
        return res.status(403).json({
          success: false,
          message: "RFID Belum di daftarkan",
        });
      }
      // mendapatkan data presensi hari ini
      const todayAttendance = await getTodayAttendance(schedule.id, user.id);
      if (!todayAttendance) {
        return res.status(403).json({
          success: false,
          message: "Tidak ada presensi untukmu",
        });
      }
      // mengecek hadir atau tidak
      if (todayAttendance.status === "hadir") {
        return res.status(403).json({
          success: true,
          message: "Presensi sudah dicatat",
        });
      }
      // mencatat presensi
      await createAttendance(todayAttendance);
      const attendancePoin = process.env.PRESENSI_POIN_REWARD;
      // menambahkan poin dan log aktivitas
      await addUserPoint(user, attendancePoin);
      await createLogActivity({
        description: `${user.nama} - ${user.id}: Hadir, point added ${attendancePoin}`,
        title: "Absensi RFID",
        type: "rfid_attendance",
        recordedBy: user.id,
      });
      return res.status(200).json({
        success: true,
        message: "Presensi sudah dicatat",
      });
    } catch (error) {
      next(error);
    }
  }
);

router.get("/status/:rfidUid", verifyDevice, async (req, res, next) => {
  try {
    const { rfidUid } = req.params;

    // Find user by RFID
    const user = await findUserByRFID(rfidUid);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: "RFID not registered",
      });
    }

    const todayAttendance = await getTodayAttendance(user.id);
    const todaySchedule = await getTodaySchedule();
    const stats = await getAttendanceStats(user.id);

    // Check schedule time if schedule exists
    let scheduleInfo = null;
    if (
      todaySchedule &&
      todaySchedule.waktuMulai &&
      todaySchedule.waktuSelesai
    ) {
      const timeCheck = checkScheduleTime(
        todaySchedule.waktuMulai,
        todaySchedule.waktuSelesai
      );

      scheduleInfo = {
        jadwalId: todaySchedule.id,
        jadwalNama: todaySchedule.nama,
        waktuMulai: todaySchedule.waktuMulai,
        waktuSelesai: todaySchedule.waktuSelesai,
        timeStatus: timeCheck.status,
        isWithinSchedule: timeCheck.isWithinSchedule,
        message: timeCheck.message,
      };
    }

    return res.status(200).json({
      success: true,
      data: {
        user: {
          id: user.id,
          nama: user.nama,
          nim: user.nim,
        },
        todayAttendance: todayAttendance
          ? {
              id: todayAttendance.id,
              status: todayAttendance.status,
              timestamp: todayAttendance.timestamp,
            }
          : null,
        schedule: scheduleInfo,
        stats: stats,
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/attendance/schedule
 * Get today's schedule information
 */
router.get("/schedule", verifyDevice, async (req, res, next) => {
  try {
    const todaySchedule = await getTodaySchedule();

    if (!todaySchedule) {
      return res.status(404).json({
        success: false,
        error: "No schedule found",
        message: "Tidak ada jadwal untuk hari ini",
      });
    }

    // Check schedule time if waktuMulai and waktuSelesai exist
    let timeCheck = null;
    if (todaySchedule.waktuMulai && todaySchedule.waktuSelesai) {
      timeCheck = checkScheduleTime(
        todaySchedule.waktuMulai,
        todaySchedule.waktuSelesai
      );
    }

    return res.status(200).json({
      success: true,
      data: {
        schedule: {
          id: todaySchedule.id,
          nama: todaySchedule.nama,
          tanggal: todaySchedule.tanggal,
          waktuMulai: todaySchedule.waktuMulai,
          waktuSelesai: todaySchedule.waktuSelesai,
          tempat: todaySchedule.tempat,
          kategori: todaySchedule.kategori,
          isAktif: todaySchedule.isAktif,
        },
        timeStatus: timeCheck,
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/attendance/health
 * Health check endpoint
 */
router.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Service is running",
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
