import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventApprovalsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get all events pending approval from event_approvals collection
  Stream<List<Map<String, dynamic>>> getPendingEventApprovals() {
    print('EventApprovalsService: Fetching pending event approvals...');
    
    return _firestore
        .collection('event_approvals')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('EventApprovalsService: Found ${snapshot.docs.length} pending approvals');
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get all event approvals (for admin view)
  Stream<List<Map<String, dynamic>>> getAllEventApprovals() {
    print('EventApprovalsService: Fetching all event approvals...');
    
    return _firestore
        .collection('event_approvals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('EventApprovalsService: Found ${snapshot.docs.length} total approvals');
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Approve an event (move from event_approvals to events with approved status)
  Future<bool> approveEvent(String approvalId) async {
    try {
      print('EventApprovalsService: Approving event with approval ID: $approvalId');
      
      // Get the approval document
      DocumentSnapshot approvalDoc = await _firestore
          .collection('event_approvals')
          .doc(approvalId)
          .get();

      if (!approvalDoc.exists) {
        print('EventApprovalsService: Approval document not found');
        return false;
      }

      Map<String, dynamic> approvalData = approvalDoc.data() as Map<String, dynamic>;

      // Create approved event in events collection
      Map<String, dynamic> eventData = Map.from(approvalData);
      eventData.remove('id'); // Remove the approval ID
      eventData['status'] = 'approved';
      eventData['approvedAt'] = FieldValue.serverTimestamp();
      eventData['approvedBy'] = _auth.currentUser?.uid;

      // Add to events collection
      DocumentReference eventRef = await _firestore.collection('events').add(eventData);
      print('EventApprovalsService: Created approved event with ID: ${eventRef.id}');

      // Update approval status
      await _firestore
          .collection('event_approvals')
          .doc(approvalId)
          .update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': _auth.currentUser?.uid,
        'eventId': eventRef.id, // Reference to the created event
      });

      print('EventApprovalsService: Successfully approved event');
      return true;
    } catch (e) {
      print('EventApprovalsService Error approving event: $e');
      return false;
    }
  }

  /// Reject an event approval
  Future<bool> rejectEvent(String approvalId, String reason) async {
    try {
      print('EventApprovalsService: Rejecting event with approval ID: $approvalId');
      
      await _firestore
          .collection('event_approvals')
          .doc(approvalId)
          .update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': _auth.currentUser?.uid,
        'rejectionReason': reason,
      });

      print('EventApprovalsService: Successfully rejected event');
      return true;
    } catch (e) {
      print('EventApprovalsService Error rejecting event: $e');
      return false;
    }
  }

  /// Submit event for approval (used by organizers)
  Future<String?> submitEventForApproval(Map<String, dynamic> eventData) async {
    try {
      print('EventApprovalsService: Submitting event for approval');
      
      // Add submission metadata
      eventData['status'] = 'pending';
      eventData['createdAt'] = FieldValue.serverTimestamp();
      eventData['submittedBy'] = _auth.currentUser?.uid;

      DocumentReference ref = await _firestore
          .collection('event_approvals')
          .add(eventData);

      print('EventApprovalsService: Submitted event for approval with ID: ${ref.id}');
      return ref.id;
    } catch (e) {
      print('EventApprovalsService Error submitting event: $e');
      return null;
    }
  }

  /// Get approval status by event ID
  Future<Map<String, dynamic>?> getApprovalStatus(String eventId) async {
    try {
      print('EventApprovalsService: Checking approval status for event: $eventId');
      
      QuerySnapshot query = await _firestore
          .collection('event_approvals')
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        Map<String, dynamic> data = query.docs.first.data() as Map<String, dynamic>;
        data['id'] = query.docs.first.id;
        return data;
      }

      return null;
    } catch (e) {
      print('EventApprovalsService Error getting approval status: $e');
      return null;
    }
  }
}
