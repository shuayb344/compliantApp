import '../models/complaint_model.dart';
import '../core/utils/helpers.dart';

class ComplaintService {
  // Mock data for initial development
  final List<ComplaintModel> _mockComplaints = [
    ComplaintModel(
      id: '1',
      refId: 'REF-8422',
      userId: 'user_123',
      userName: 'Alex Thompson',
      title: 'Unable to process monthly subscription payment',
      description: 'The portal keeps returning an error every time I try to update my card details. I have tried three different cards from different banks, but the result is the same. Please assist as my subscription is about to expire.',
      category: 'Billing',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      statusHistory: [
        StatusHistoryEntry(
          status: 'pending',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          note: 'Complaint received and awaiting initial review.',
        ),
      ],
    ),
    ComplaintModel(
      id: '2',
      refId: 'REF-9012',
      userId: 'user_456',
      userName: 'Sarah Jenkins',
      title: 'Dashboard analytics not refreshing in real-time',
      description: 'The analytics charts on the mobile dashboard are not refreshing even when I pull to refresh. I have to restart the app every time to see the latest data. This is impacting my ability to monitor performance.',
      category: 'Technical',
      status: 'in_progress',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      statusHistory: [
        StatusHistoryEntry(
          status: 'pending',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          note: 'Complaint received and awaiting initial review.',
        ),
        StatusHistoryEntry(
          status: 'in_progress',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          note: 'Task assigned to the Technical Support Team.',
        ),
      ],
    ),
    ComplaintModel(
      id: '3',
      refId: 'REF-8802',
      userId: 'user_123',
      userName: 'Alex Thompson',
      title: 'Unfinished Road Maintenance on Oak Avenue',
      description: 'The maintenance work on Oak Avenue between 4th and 6th Street was abruptly halted three days ago. Currently, there are several large potholes left unfilled and hazardous loose gravel across the primary lane. This is causing significant traffic congestion during peak hours and poses a risk to cyclists and vehicles. We request an immediate update on the timeline for completion.',
      category: 'Infrastructure',
      status: 'resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 10)),
      statusHistory: [
        StatusHistoryEntry(
          status: 'pending',
          timestamp: DateTime.now().subtract(const Duration(days: 10, hours: 2)),
          note: 'Complaint received and awaiting initial review.',
        ),
        StatusHistoryEntry(
          status: 'in_progress',
          timestamp: DateTime.now().subtract(const Duration(days: 8, hours: 5)),
          note: 'Task assigned to the Public Works Department.',
        ),
        StatusHistoryEntry(
          status: 'resolved',
          timestamp: DateTime.now().subtract(const Duration(hours: 10, minutes: 15)),
          note: 'The maintenance crew has completed the resurfacing work.',
        ),
      ],
      adminResponse: AdminResponse(
        message: 'We apologize for the delay. The delay was due to an unforeseen utility line issue that required coordination with the water department. The resurfacing is now completed, and the road is fully open. Thank you for your patience.',
        respondedBy: 'James T. Carter',
        respondedByTitle: 'Public Works Supervisor',
        respondedAt: DateTime.now().subtract(const Duration(hours: 10, minutes: 15)),
        verified: true,
      ),
    ),
  ];

  Stream<List<ComplaintModel>> getComplaints({String? userId}) {
    // Simulate Firestore stream
    return Stream.value(
      userId == null
          ? _mockComplaints
          : _mockComplaints.where((c) => c.userId == userId).toList(),
    ).map((list) => list..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> submitComplaint(ComplaintModel complaint) async {
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));
    _mockComplaints.add(complaint);
  }

  Future<void> updateComplaintStatus(String id, String status, String note) async {
    await Future.delayed(const Duration(milliseconds: 500));
    int index = _mockComplaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      final complaint = _mockComplaints[index];
      final newHistory = List<StatusHistoryEntry>.from(complaint.statusHistory)
        ..add(StatusHistoryEntry(
          status: status,
          timestamp: DateTime.now(),
          note: note,
        ));
      
      _mockComplaints[index] = complaint.copyWith(
        status: status,
        statusHistory: newHistory,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> addAdminResponse(String id, AdminResponse response) async {
    await Future.delayed(const Duration(milliseconds: 500));
    int index = _mockComplaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      _mockComplaints[index] = _mockComplaints[index].copyWith(
        adminResponse: response,
        updatedAt: DateTime.now(),
      );
    }
  }
}
