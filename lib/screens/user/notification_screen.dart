import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (user != null) {
                provider.fetchNotifications(user.uid);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: provider.notifications.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppStrings.recentAlerts,
                                  style: AppStyles.heading2Of(context)),
                              const SizedBox(height: 4),
                              Text(AppStrings.alertsSubtitle,
                                  style: AppStyles.bodySmallOf(context)),
                            ],
                          ),
                        ),
                        if (provider.unreadCount > 0)
                          TextButton(
                            onPressed: () => user != null
                                ? provider.markAllAsRead(user.uid)
                                : null,
                            child: Text(
                              AppStrings.markAllAsRead,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                final n = provider.notifications[index - 1];
                return _buildNotificationCard(n, context, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      NotificationModel n, BuildContext context, NotificationProvider provider) {
    final icon = Helpers.getNotificationIcon(n.type);
    final color = Helpers.getNotificationColor(n.type);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        provider.markAsRead(n.id);
        Navigator.pushNamed(
          context,
          AppRoutes.complaintDetail,
          arguments: n.complaintId,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.cardDecorationOf(context).copyWith(
          border: n.isRead ? null : Border.all(color: AppColors.accent, width: 1),
        ),
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
                          style: TextStyle(
                            fontWeight:
                                n.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        Helpers.formatTimeAgo(n.createdAt),
                        style: AppStyles.bodySmallOf(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: AppStyles.cardDescriptionOf(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none,
                  color: theme.colorScheme.primary, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.allCaughtUp,
              style: AppStyles.heading2Of(context),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noUnreadNotifications,
              textAlign: TextAlign.center,
              style: AppStyles.subtitleOf(context),
            ),
          ],
        ),
      ),
    );
  }
}
