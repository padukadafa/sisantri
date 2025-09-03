import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Initialize Firebase first
  // Testing Firestore connection

  try {
    final firestore = FirebaseFirestore.instance;

    // Test basic connection
    await firestore.collection('presensi').limit(1).get();
    // Connection OK

    // Get all presensi documents
    final allSnapshot = await firestore.collection('presensi').get();
    // Total documents retrieved

    // Show sample documents
    if (allSnapshot.docs.isNotEmpty) {
      // Sample documents
      for (int i = 0; i < 3 && i < allSnapshot.docs.length; i++) {
        // Document details
        // Data retrieved
        // ---
      }
    }

    // Test date range query
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1); // First day of month
    final endDate = DateTime(now.year, now.month + 1, 0); // Last day of month

    // Date range set

    await firestore
        .collection('presensi')
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    // Documents in current month retrieved
  } catch (e) {
    // Error occurred
  }
}
