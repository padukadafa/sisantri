import 'dart:io';
import 'package:excel/excel.dart' as excel_lib;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sisantri/shared/models/presensi_model.dart';
import 'package:sisantri/shared/models/user_model.dart';
import 'attendance_report_provider.dart';

/// Service untuk export laporan presensi ke Excel dengan format yang informatif dan rapi
class ExcelExportService {
  /// Generate nama file Excel
  static String _generateFileName(AttendanceReportFilter filter) {
    final dateFormat = DateFormat('yyyyMMdd');
    final now = DateTime.now();

    String periodStr = 'all';
    if (filter.startDate != null && filter.endDate != null) {
      periodStr =
          '${dateFormat.format(filter.startDate!)}_${dateFormat.format(filter.endDate!)}';
    }

    return 'laporan_presensi_${periodStr}_${dateFormat.format(now)}.xlsx';
  }

  /// Export laporan presensi ke Excel
  static Future<String> exportToExcel({
    required Map<String, dynamic> reportData,
    required AttendanceReportFilter filter,
  }) async {
    // Request storage permission untuk Android
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        final manageStatus = await Permission.manageExternalStorage.request();
        if (!manageStatus.isGranted) {
          throw Exception('Storage permission not granted');
        }
      }
    }

    // Buat Excel file
    final excel = excel_lib.Excel.createExcel();

    final statistics = reportData['statistics'] as Map<String, dynamic>;
    final attendanceRecords =
        reportData['attendanceRecords'] as List<PresensiModel>;
    final users = reportData['users'] as List<UserModel>;
    final userSummary =
        reportData['userSummary'] as Map<String, Map<String, dynamic>>;

    // Buat sheets
    final summarySheet = excel['Ringkasan'];
    final detailSheet = excel['Detail'];
    final santriSheet = excel['Per Santri'];

    _createSummarySheet(summarySheet, statistics, filter);
    _createDetailSheet(detailSheet, attendanceRecords, users);
    _createSantriSummarySheet(santriSheet, userSummary);

    // Tentukan directory untuk menyimpan file
    Directory? directory;

    if (Platform.isAndroid) {
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await publicDownloads.exists()) {
        directory = publicDownloads;
      } else {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          directory = Directory('${directory.path}/Downloads');
        }
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final fileName = _generateFileName(filter);
    final filePath = directory != null
        ? '${directory.path}/$fileName'
        : fileName;

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);

      // Pastikan directory exists
      await file.parent.create(recursive: true);

      // Tulis file
      await file.writeAsBytes(fileBytes);

      // Verify file created
      if (await file.exists()) {
        await file.length();
      } else {
        throw Exception('File was not created after writing');
      }
    } else {
      throw Exception('Failed to generate Excel file bytes');
    }

    return filePath;
  }

  /// Buka file Excel yang sudah di-export
  static Future<void> openExportedFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      throw Exception('Failed to open file: $e');
    }
  }

  /// Buat sheet ringkasan dengan statistik lengkap
  static void _createSummarySheet(
    excel_lib.Sheet sheet,
    Map<String, dynamic> stats,
    AttendanceReportFilter filter,
  ) {
    int row = 0;

    // === HEADER ===
    _setCell(sheet, row, 0, 'LAPORAN RINGKASAN PRESENSI SANTRI', bold: true);
    row++;
    _setCell(
      sheet,
      row,
      0,
      'Tanggal Cetak: ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
    );
    row += 2;

    // === INFORMASI PERIODE ===
    _setCell(sheet, row, 0, 'INFORMASI PERIODE', bold: true);
    row++;

    _setCell(sheet, row, 0, 'Periode:', bold: true);
    if (filter.startDate != null && filter.endDate != null) {
      _setCell(
        sheet,
        row,
        1,
        '${DateFormat('dd MMMM yyyy', 'id_ID').format(filter.startDate!)} - ${DateFormat('dd MMMM yyyy', 'id_ID').format(filter.endDate!)}',
      );
    } else {
      _setCell(sheet, row, 1, 'Semua Data');
    }
    row++;

    if (filter.status != null) {
      _setCell(sheet, row, 0, 'Filter Status:', bold: true);
      _setCell(sheet, row, 1, filter.status!);
      row++;
    }
    row++;

    // === STATISTIK KESELURUHAN ===
    _setCell(sheet, row, 0, 'STATISTIK KESELURUHAN', bold: true);
    row++;

    // Header tabel
    _setCell(sheet, row, 0, 'Keterangan', bold: true);
    _setCell(sheet, row, 1, 'Jumlah', bold: true);
    _setCell(sheet, row, 2, 'Persentase', bold: true);
    row++;

    // Data statistik
    final totalRecords = stats['totalRecords'] as int;
    final presentCount = stats['presentCount'] as int;
    final sickCount = stats['sickCount'] as int;
    final excusedCount = stats['excusedCount'] as int;
    final absentCount = stats['absentCount'] as int;

    _setCell(sheet, row, 0, 'Total Presensi', bold: true);
    _setCell(sheet, row, 1, totalRecords.toString());
    _setCell(sheet, row, 2, '100.0%');
    row++;

    _setCell(sheet, row, 0, '✓ Hadir');
    _setCell(sheet, row, 1, presentCount.toString());
    _setCell(
      sheet,
      row,
      2,
      totalRecords > 0
          ? '${(presentCount / totalRecords * 100).toStringAsFixed(1)}%'
          : '0.0%',
    );
    row++;

    _setCell(sheet, row, 0, '⚕ Sakit');
    _setCell(sheet, row, 1, sickCount.toString());
    _setCell(
      sheet,
      row,
      2,
      totalRecords > 0
          ? '${(sickCount / totalRecords * 100).toStringAsFixed(1)}%'
          : '0.0%',
    );
    row++;

    _setCell(sheet, row, 0, 'ℹ Izin');
    _setCell(sheet, row, 1, excusedCount.toString());
    _setCell(
      sheet,
      row,
      2,
      totalRecords > 0
          ? '${(excusedCount / totalRecords * 100).toStringAsFixed(1)}%'
          : '0.0%',
    );
    row++;

    _setCell(sheet, row, 0, '✗ Alpha');
    _setCell(sheet, row, 1, absentCount.toString());
    _setCell(
      sheet,
      row,
      2,
      totalRecords > 0
          ? '${(absentCount / totalRecords * 100).toStringAsFixed(1)}%'
          : '0.0%',
    );
    row += 2;

    // Tingkat kehadiran
    _setCell(sheet, row, 0, 'TINGKAT KEHADIRAN:', bold: true);
    _setCell(
      sheet,
      row,
      1,
      '${stats['attendanceRate'].toStringAsFixed(1)}%',
      bold: true,
    );

    // Set column widths
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 15);
  }

  /// Buat sheet detail presensi harian
  static void _createDetailSheet(
    excel_lib.Sheet sheet,
    List<PresensiModel> records,
    List<UserModel> users,
  ) {
    int row = 0;

    // === HEADER ===
    _setCell(sheet, row, 0, 'DETAIL PRESENSI HARIAN', bold: true);
    row++;
    _setCell(sheet, row, 0, 'Total ${records.length} record presensi');
    row += 2;

    // === TABLE HEADERS ===
    _setCell(sheet, row, 0, 'No', bold: true);
    _setCell(sheet, row, 1, 'Nama Santri', bold: true);
    _setCell(sheet, row, 2, 'Tanggal', bold: true);
    _setCell(sheet, row, 3, 'Hari', bold: true);
    _setCell(sheet, row, 4, 'Jam', bold: true);
    _setCell(sheet, row, 5, 'Status', bold: true);
    _setCell(sheet, row, 6, 'Keterangan', bold: true);
    row++;

    // === DATA ROWS ===
    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      final user = users.firstWhere(
        (u) => u.id == record.userId,
        orElse: () =>
            UserModel(id: '', nama: 'Unknown', email: '', role: 'santri'),
      );

      _setCell(sheet, row, 0, (i + 1).toString());
      _setCell(sheet, row, 1, user.nama);
      _setCell(
        sheet,
        row,
        2,
        DateFormat('dd/MM/yyyy').format(record.createdAt),
      );
      _setCell(
        sheet,
        row,
        3,
        DateFormat('EEEE', 'id_ID').format(record.createdAt),
      );
      _setCell(
        sheet,
        row,
        4,
        record.timestamp != null
            ? DateFormat('HH:mm:ss').format(record.timestamp!)
            : '-',
      );
      _setCell(sheet, row, 5, record.status.label);
      _setCell(
        sheet,
        row,
        6,
        record.keterangan.isEmpty ? '-' : record.keterangan,
      );

      row++;
    }

    // Set column widths
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 12);
    sheet.setColumnWidth(5, 12);
    sheet.setColumnWidth(6, 35);
  }

  /// Buat sheet ringkasan per santri dengan kategori performa
  static void _createSantriSummarySheet(
    excel_lib.Sheet sheet,
    Map<String, Map<String, dynamic>> userSummary,
  ) {
    int row = 0;

    // === HEADER ===
    _setCell(sheet, row, 0, 'RINGKASAN PRESENSI PER SANTRI', bold: true);
    row++;
    _setCell(sheet, row, 0, 'Total ${userSummary.length} santri');
    row += 2;

    // === TABLE HEADERS ===
    _setCell(sheet, row, 0, 'No', bold: true);
    _setCell(sheet, row, 1, 'Nama Santri', bold: true);
    _setCell(sheet, row, 2, 'Total Presensi', bold: true);
    _setCell(sheet, row, 3, 'Hadir', bold: true);
    _setCell(sheet, row, 4, 'Sakit', bold: true);
    _setCell(sheet, row, 5, 'Izin', bold: true);
    _setCell(sheet, row, 6, 'Alpha', bold: true);
    _setCell(sheet, row, 7, 'Tingkat Kehadiran', bold: true);
    _setCell(sheet, row, 8, 'Kategori', bold: true);
    row++;

    // Sort by attendance rate (descending)
    final sortedEntries = userSummary.entries.toList()
      ..sort((a, b) {
        final rateA = a.value['attendanceRate'] as double;
        final rateB = b.value['attendanceRate'] as double;
        return rateB.compareTo(rateA);
      });

    // === DATA ROWS ===
    int no = 1;
    for (final entry in sortedEntries) {
      final summary = entry.value;
      final user = summary['user'] as UserModel;
      final attendanceRate = summary['attendanceRate'] as double;

      // Tentukan kategori
      String kategori;
      if (attendanceRate >= 90) {
        kategori = '⭐ Excellent';
      } else if (attendanceRate >= 80) {
        kategori = '✓ Baik';
      } else if (attendanceRate >= 70) {
        kategori = '○ Cukup';
      } else if (attendanceRate >= 60) {
        kategori = '△ Kurang';
      } else {
        kategori = '✗ Perlu Perhatian';
      }

      _setCell(sheet, row, 0, no.toString());
      _setCell(sheet, row, 1, user.nama);
      _setCell(sheet, row, 2, summary['totalRecords'].toString());
      _setCell(sheet, row, 3, summary['presentCount'].toString());
      _setCell(sheet, row, 4, summary['sickCount'].toString());
      _setCell(sheet, row, 5, summary['excusedCount'].toString());
      _setCell(sheet, row, 6, summary['absentCount'].toString());
      _setCell(
        sheet,
        row,
        7,
        '${attendanceRate.toStringAsFixed(1)}%',
        bold: true,
      );
      _setCell(sheet, row, 8, kategori);

      row++;
      no++;
    }

    // === FOOTER SUMMARY ===
    row++;
    _setCell(sheet, row, 0, 'RINGKASAN', bold: true);

    // Hitung total
    int totalAllRecords = 0;
    int totalAllPresent = 0;
    int totalAllSick = 0;
    int totalAllExcused = 0;
    int totalAllAbsent = 0;

    for (final entry in userSummary.entries) {
      final summary = entry.value;
      totalAllRecords += summary['totalRecords'] as int;
      totalAllPresent += summary['presentCount'] as int;
      totalAllSick += summary['sickCount'] as int;
      totalAllExcused += summary['excusedCount'] as int;
      totalAllAbsent += summary['absentCount'] as int;
    }

    final overallRate = totalAllRecords > 0
        ? (totalAllPresent / totalAllRecords * 100)
        : 0.0;

    _setCell(sheet, row, 2, totalAllRecords.toString(), bold: true);
    _setCell(sheet, row, 3, totalAllPresent.toString(), bold: true);
    _setCell(sheet, row, 4, totalAllSick.toString(), bold: true);
    _setCell(sheet, row, 5, totalAllExcused.toString(), bold: true);
    _setCell(sheet, row, 6, totalAllAbsent.toString(), bold: true);
    _setCell(sheet, row, 7, '${overallRate.toStringAsFixed(1)}%', bold: true);

    // Set column widths
    sheet.setColumnWidth(0, 6);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 12);
    sheet.setColumnWidth(3, 10);
    sheet.setColumnWidth(4, 10);
    sheet.setColumnWidth(5, 10);
    sheet.setColumnWidth(6, 10);
    sheet.setColumnWidth(7, 16);
    sheet.setColumnWidth(8, 18);
  }

  /// Helper method untuk set cell value dengan styling sederhana
  static void _setCell(
    excel_lib.Sheet sheet,
    int row,
    int col,
    String value, {
    bool bold = false,
  }) {
    final cell = sheet.cell(
      excel_lib.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
    );
    cell.value = excel_lib.TextCellValue(value);

    if (bold) {
      cell.cellStyle = excel_lib.CellStyle(bold: true);
    }
  }
}
