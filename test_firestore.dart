import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Initialize Firebase first
  print('Testing Firestore connection...');

  try {
    final firestore = FirebaseFirestore.instance;

    // Test basic connection
    print('1. Testing basic connection...');
    final testSnapshot = await firestore.collection('presensi').limit(1).get();
    print('   Connection OK. Test docs: ${testSnapshot.docs.length}');

    // Get all presensi documents
    print('2. Getting all presensi documents...');
    final allSnapshot = await firestore.collection('presensi').get();
    print('   Total documents: ${allSnapshot.docs.length}');

    // Show sample documents
    if (allSnapshot.docs.isNotEmpty) {
      print('3. Sample documents:');
      for (int i = 0; i < 3 && i < allSnapshot.docs.length; i++) {
        final doc = allSnapshot.docs[i];
        print('   Doc ${i + 1}: ${doc.id}');
        print('   Data: ${doc.data()}');
        print('   ---');
      }
    }

    // Test date range query
    print('4. Testing date range query...');
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1); // First day of month
    final endDate = DateTime(now.year, now.month + 1, 0); // Last day of month

    print('   Date range: $startDate to $endDate');

    final dateQuery = await firestore
        .collection('presensi')
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    print('   Documents in current month: ${dateQuery.docs.length}');
  } catch (e) {
    print('Error: $e');
  }
}
