import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Test basic Firebase connection
  Future<bool> testConnection() async {
    try {
      // Try to read from a simple collection
      final testQuery = await _firestore
          .collection('events')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      
      print('Firebase connection test successful');
      print('Found ${testQuery.docs.length} document(s) in events collection');
      
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }

  /// Get all events without any filters for debugging
  Future<List<Map<String, dynamic>>> getAllEventsDebug() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .get()
          .timeout(const Duration(seconds: 15));

      final events = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      print('Total events found: ${events.length}');
      
      // Count events by status
      final statusCounts = <String, int>{};
      for (var event in events) {
        final status = event['status']?.toString() ?? 'null';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
      
      print('Events by status: $statusCounts');
      
      return events;
    } catch (e) {
      print('Error getting all events: $e');
      rethrow;
    }
  }

  /// Check if current user has admin permissions
  Future<bool> checkAdminPermissions() async {
    try {
      // Try to write to a test collection
      await _firestore
          .collection('admin_test')
          .doc('test_doc')
          .set({
            'test': true,
            'timestamp': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 10));

      // Clean up
      await _firestore
          .collection('admin_test')
          .doc('test_doc')
          .delete();

      print('Admin permissions test successful');
      return true;
    } catch (e) {
      print('Admin permissions test failed: $e');
      return false;
    }
  }

  /// Test specific queries that the moderation screen uses
  Future<void> testModerationQueries() async {
    print('Testing moderation queries...');
    
    try {
      // Test 1: Simple where query
      print('Test 1: Simple where query...');
      final simpleQuery = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'pending')
          .get()
          .timeout(const Duration(seconds: 10));
      print('Simple query successful: ${simpleQuery.docs.length} pending events');

      // Test 2: Where + orderBy query
      print('Test 2: Where + orderBy query...');
      try {
        final orderByQuery = await _firestore
            .collection('events')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .get()
            .timeout(const Duration(seconds: 10));
        print('OrderBy query successful: ${orderByQuery.docs.length} pending events');
      } catch (e) {
        print('OrderBy query failed (likely missing index): $e');
      }

      // Test 3: Stream query
      print('Test 3: Stream query...');
      final streamController = _firestore
          .collection('events')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen(
            (snapshot) {
              print('Stream update: ${snapshot.docs.length} pending events');
            },
            onError: (error) {
              print('Stream error: $error');
            },
          );

      // Cancel stream after 5 seconds
      await Future.delayed(const Duration(seconds: 5));
      streamController.cancel();
      print('Stream test completed');

    } catch (e) {
      print('Moderation queries test failed: $e');
    }
  }
}
