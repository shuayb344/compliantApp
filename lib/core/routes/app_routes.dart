import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/user/user_home_screen.dart';
import '../../screens/user/submit_complaint_screen.dart';
import '../../screens/user/complaint_detail_screen.dart';
import '../../screens/user/notification_screen.dart';
import '../../screens/user/profile_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_complaint_detail_screen.dart';
import '../../screens/admin/admin_notification_screen.dart';
import '../../models/complaint_model.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String userHome = '/user/home';
  static const String submitComplaint = '/user/submit-complaint';
  static const String complaintDetail = '/user/complaint-detail';
  static const String userNotifications = '/user/notifications';
  static const String userProfile = '/user/profile';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminComplaintDetail = '/admin/complaint-detail';
  static const String adminNotifications = '/admin/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case register:
        return _buildRoute(const RegisterScreen(), settings);
      case userHome:
        return _buildRoute(const UserHomeScreen(), settings);
      case submitComplaint:
        return _buildRoute(const SubmitComplaintScreen(), settings);
      case complaintDetail:
        final complaint = settings.arguments as ComplaintModel;
        return _buildRoute(
          ComplaintDetailScreen(complaint: complaint),
          settings,
        );
      case userNotifications:
        return _buildRoute(const NotificationScreen(), settings);
      case userProfile:
        return _buildRoute(const ProfileScreen(), settings);
      case adminDashboard:
        return _buildRoute(const AdminDashboardScreen(), settings);
      case adminComplaintDetail:
        final complaint = settings.arguments as ComplaintModel;
        return _buildRoute(
          AdminComplaintDetailScreen(complaint: complaint),
          settings,
        );
      case adminNotifications:
        return _buildRoute(const AdminNotificationScreen(), settings);
      default:
        return _buildRoute(const LoginScreen(), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
