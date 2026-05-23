import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart';
import '../models/message_model.dart';
import '../core/utils/helpers.dart';

class ComplaintService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'complaints';

  // Get real-time stream of complaints
  Stream<List<ComplaintModel>> getComplaints({String? userId}) {
    Query query = _db.collection(_collection).orderBy('createdAt', descending: true);

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ComplaintModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();
    });
  }

  // Submit a new complaint
  Future<void> submitComplaint(ComplaintModel complaint, {List<File>? images}) async {
    try {
      // Create a unique document ID first
      final docRef = _db.collection(_collection).doc();
      final String complaintId = docRef.id;

      List<String> imageUrls = [];
      
      if (images != null && images.isNotEmpty) {
        for (var i = 0; i < images.length; i++) {
          String? url = await uploadImage(images[i], complaintId, i);
          if (url != null) imageUrls.add(url);
        }
      }

      // Generate a short Ref ID if not provided
      final String refId = 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final newComplaint = complaint.copyWith(
        id: complaintId,
        refId: refId,
        attachments: imageUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        statusHistory: [
          StatusHistoryEntry(
            status: 'pending',
            timestamp: DateTime.now(),
            note: 'Complaint submitted successfully.',
          ),
        ],
      );

      await docRef.set(newComplaint.toJson());
      
      // Create notification for admin (Optional logic could go here)
    } catch (e) {
      log('Error submitting complaint: $e');
      rethrow;
    }
  }

  // Upload image to Storage
  Future<String?> uploadImage(File file, String complaintId, int index) async {
    try {
      final String fileName = 'image_$index.jpg';
      final ref = _storage.ref().child('complaints').child(complaintId).child(fileName);
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  // Update complaint status
  Future<void> updateComplaintStatus(String id, String status, String note) async {
    try {
      final docRef = _db.collection(_collection).doc(id);
      final doc = await docRef.get();
      
      if (!doc.exists) return;

      final complaint = ComplaintModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
      
      final newHistory = List<StatusHistoryEntry>.from(complaint.statusHistory)
        ..add(StatusHistoryEntry(
          status: status,
          timestamp: DateTime.now(),
          note: note,
        ));
      
      await docRef.update({
        'status': status,
        'statusHistory': newHistory.map((e) => e.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Trigger notification logic would go here
      await _createNotification(
        complaint.userId,
        'Complaint Updated',
        'Your complaint (${complaint.refId}) status has been changed to ${status.replaceAll('_', ' ')}.',
        id,
        status == 'resolved' ? 'resolved' : 'status_update',
      );
    } catch (e) {
      log('Error updating status: $e');
      rethrow;
    }
  }

  // Add admin response
  Future<void> addAdminResponse(String id, AdminResponse response) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'adminResponse': response.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error adding admin response: $e');
      rethrow;
    }
  }

  // Delete complaint
  Future<void> deleteComplaint(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
      // Also delete images from storage
      final storageRef = _storage.ref().child('complaints').child(id);
      final listResult = await storageRef.listAll();
      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      log('Error deleting complaint: $e');
      rethrow;
    }
  }

  // Create notification in Firestore
  Future<void> _createNotification(String userId, String title, String body, String complaintId, String type) async {
    try {
      await _db.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': body, // Note: model uses 'message', service used 'body'
        'type': type,
        'complaintId': complaintId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error creating notification: $e');
    }
  }

  // ── Chat Logic (Existing but fixed) ────────────────────────────────

  Stream<List<MessageModel>> getMessages(String complaintId) {
    return _db
        .collection(_collection)
        .doc(complaintId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id)).toList();
    });
  }

  Future<void> sendMessage(String complaintId, MessageModel message) async {
    await _db
        .collection(_collection)
        .doc(complaintId)
        .collection('messages')
        .add(message.toJson());
  }

  void log(String message) {
    print('ComplaintService: $message');
  }
}
