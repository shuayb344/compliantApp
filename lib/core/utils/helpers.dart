import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../constants/app_colors.dart';

class Helpers {
  Helpers._();

  /// Generate a unique reference ID like "REF-JK-9021"
  static String generateRefId() {
    final random = Random();
    final letters = String.fromCharCodes(
      List.generate(2, (_) => random.nextInt(26) + 65),
    );
    final numbers = (random.nextInt(9000) + 1000).toString();
    return 'REF-$letters-$numbers';
  }

  /// Format date like "October 24, 2023"
  static String formatDateFull(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  /// Format date like "Oct 24, 2023"
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Format date like "Oct 24, 02:15 PM"
  static String formatDateWithTime(DateTime date) {
    return DateFormat('MMM d, hh:mm a').format(date);
  }

  /// Format relative time like "2 mins ago", "1 day ago"
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDateShort(date);
    }
  }

  /// Get days pending string
  static String getDaysPending(DateTime createdAt) {
    final days = DateTime.now().difference(createdAt).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return '1 day pending';
    return '$days days pending';
  }

  /// Get color for complaint status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'in_progress':
        return AppColors.inProgress;
      case 'resolved':
        return AppColors.resolved;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get background color for complaint status
  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pendingBg;
      case 'in_progress':
        return AppColors.inProgressBg;
      case 'resolved':
        return AppColors.resolvedBg;
      default:
        return AppColors.surfaceLight;
    }
  }

  /// Get display text for status
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'resolved':
        return 'RESOLVED';
      default:
        return status.toUpperCase();
    }
  }

  /// Get color for category
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'billing':
        return AppColors.billing;
      case 'technical':
        return AppColors.technical;
      case 'service':
        return AppColors.service;
      case 'infrastructure':
        return AppColors.infrastructure;
      default:
        return AppColors.accent;
    }
  }

  /// Get icon for notification type
  static IconData getNotificationIcon(String type) {
    switch (type) {
      case 'status_update':
        return Icons.check_circle;
      case 'action_required':
        return Icons.warning_rounded;
      case 'resolved':
        return Icons.notifications_outlined;
      case 'new_complaint':
        return Icons.description_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  /// Get color for notification type
  static Color getNotificationColor(String type) {
    switch (type) {
      case 'status_update':
        return AppColors.statusUpdate;
      case 'action_required':
        return AppColors.actionRequired;
      case 'resolved':
        return AppColors.textSecondary;
      case 'new_complaint':
        return AppColors.newComplaint;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Show a snackbar
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
