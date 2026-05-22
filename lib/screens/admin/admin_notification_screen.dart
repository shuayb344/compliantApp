import 'package:flutter/material.dart';
import '../user/notification_screen.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reusing user's notification screen with admin context
    return const NotificationScreen();
  }
}
