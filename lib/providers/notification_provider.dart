import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      userId: 'user_123',
      complaintId: '1234',
      title: 'Complaint #1234 Status Update',
      message: 'Your complaint has been moved to In Progress. A support agent is currently reviewing the details.',
      type: 'status_update',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    NotificationModel(
      id: '2',
      userId: 'user_123',
      complaintId: '1182',
      title: 'Action Required: Complaint #1182',
      message: 'Additional documentation is required to proceed with your request. Please check your email for details.',
      type: 'action_required',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    NotificationModel(
      id: '3',
      userId: 'user_123',
      complaintId: '1105',
      title: 'Complaint #1105 Resolved',
      message: 'This case has been marked as resolved. We would love to hear your feedback on the resolution process.',
      type: 'resolved',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: '4',
      userId: 'user_123',
      complaintId: '1234',
      title: 'New Complaint Registered',
      message: 'Case #1234 has been successfully opened. Expect an update within 24 business hours.',
      type: 'new_complaint',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    int index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }
}
