import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/complaint_model.dart';
import '../models/message_model.dart';

class ComplaintService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Cloudinary configuration
  final _cloudinary = CloudinaryPublic('degstpmjo', 'complaints_app', cache: false);
  
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
      final docRef = _db.collection(_collection).doc();
      final String complaintId = docRef.id;

      List<String> imageUrls = [];
      
      if (images != null && images.isNotEmpty) {
        log('Uploading ${images.length} image(s) to Cloudinary...');
        for (var i = 0; i < images.length; i++) {
          final file = images[i];
          log('Uploading image ${i + 1}: ${file.path} (exists: ${file.existsSync()}, size: ${file.existsSync() ? file.lengthSync() : 0} bytes)');
          try {
            String url = await uploadImage(file);
            imageUrls.add(url);
            log('Upload ${i + 1} successful: $url');
          } catch (e) {
            log('Upload ${i + 1} failed: $e');
            // Continue with other images even if one fails
          }
        }
        log('Total successful uploads: ${imageUrls.length}/${images.length}');
      }

      // Generate a short Ref ID if not provided
      final String refId = complaint.refId.isEmpty 
          ? 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
          : complaint.refId;

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

      log('Saving complaint with ${imageUrls.length} attachment URL(s)');
      await docRef.set(newComplaint.toJson());
    } catch (e) {
      log('Error submitting complaint: $e');
      rethrow;
    }
  }

  // Upload image to Cloudinary
  Future<String> uploadImage(File file) async {
    try {
      log('Cloudinary config - cloud: degstpmjo, preset: complaints_app');
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: 'complaints',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      log('Cloudinary response URL: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      log('Error uploading to Cloudinary: $e');
      rethrow;
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
      // Note: Cloudinary deletion requires API Secret, which is not safe to store on client.
      // Usually images are left or managed via a backend.
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
        'message': body,
        'type': type,
        'complaintId': complaintId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error creating notification: $e');
    }
  }

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
