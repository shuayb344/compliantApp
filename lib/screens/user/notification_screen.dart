import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/helpers.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          AppStrings.appName,
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.recentAlerts, style: AppStyles.heading2),
                        const SizedBox(height: 4),
                        Text(AppStrings.alertsSubtitle, style: AppStyles.bodySmall),
                      ],
                    ),
                    TextButton(
                      onPressed: () => provider.markAllAsRead(),
                      child: const Text(
                        AppStrings.markAllAsRead,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Notifications grouped by date (Mocking grouping)
                ...provider.notifications.map((n) => _buildNotificationCard(n, context)),
                
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    AppStrings.yesterday,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHint,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Yesterday's notifications (Mocking older once)
                _buildEmptyState(isSmall: true),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel n, BuildContext context) {
    final icon = Helpers.getNotificationIcon(n.type);
    final color = Helpers.getNotificationColor(n.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Text(
                      Helpers.formatTimeAgo(n.createdAt),
                      style: AppStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.message,
                  style: AppStyles.cardDescription,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool isSmall = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 24 : 40),
      decoration: AppStyles.primaryGradientDecoration,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mail_outline, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 24),
          const Text(
            AppStrings.allCaughtUp,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noUnreadNotifications,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
