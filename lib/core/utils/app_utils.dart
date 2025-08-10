import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility functions untuk aplikasi SiSantri
class AppUtils {
  /// Format tanggal menjadi string readable
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format waktu menjadi string HH:mm
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format tanggal dan waktu lengkap
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
  }

  /// Format relatif waktu (berapa jam/hari yang lalu)
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Check apakah email valid
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Check apakah password kuat
  static bool isStrongPassword(String password) {
    // Minimal 6 karakter, mengandung huruf dan angka
    return password.length >= 6 &&
        RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(password);
  }

  /// Kapitalisasi huruf pertama setiap kata
  static String capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Truncate text dengan ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Generate random string untuk ID
  static String generateId() {
    final now = DateTime.now();
    return now.millisecondsSinceEpoch.toString();
  }

  /// Check apakah tanggal adalah hari ini
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check apakah tanggal adalah besok
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Get greeting berdasarkan waktu
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  /// Convert Firestore timestamp ke DateTime
  static DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;

    try {
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        return timestamp.toDate();
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      print('Error converting timestamp: $e');
    }

    return null;
  }

  /// Show snackbar helper
  static void showSnackBar(
    context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    context, {
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Tidak',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
