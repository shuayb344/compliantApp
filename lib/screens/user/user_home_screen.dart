import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/complaint_card.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<ComplaintProvider>(context, listen: false).fetchComplaints(userId: user.uid);
      }
    });
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;
    
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.userComplaints);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.userNotifications);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.userProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircleAvatar(
            backgroundColor: AppColors.surfaceLight,
            child: Text(
              user?.name[0].toUpperCase() ?? 'U',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: const Text(
          AppStrings.appName,
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.userProfile),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
        unreadNotifications: Provider.of<NotificationProvider>(context).unreadCount,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.submitComplaint),
        backgroundColor: Colors.deepOrangeAccent,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await Provider.of<ComplaintProvider>(context, listen: false)
                .fetchComplaints(userId: user.uid);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.welcomeBack, style: AppStyles.bodySmall),
              Text('${AppStrings.hello}${user?.name.split(' ')[0] ?? 'User'}',
                  style: AppStyles.heading2),
              const SizedBox(height: 24),

              // Total Reports Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppStyles.primaryGradientDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.totalReports,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Consumer<ComplaintProvider>(
                          builder: (context, provider, _) => Text(
                            provider.totalCount.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Row
              Consumer<ComplaintProvider>(
                builder: (context, provider, _) => Row(
                  children: [
                    _buildSummaryCard(
                      AppStrings.pendingLabel,
                      provider.pendingCount.toString().padLeft(2, '0'),
                      AppStrings.tasks,
                      AppColors.pending,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      AppStrings.resolvedLabel,
                      provider.resolvedCount.toString().padLeft(2, '0'),
                      AppStrings.closed,
                      AppColors.resolved,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Recent Complaints Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.recentComplaints, style: AppStyles.heading3),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.userComplaints),
                    child: const Text(AppStrings.seeAll, style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Complaints List
              Consumer<ComplaintProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.complaints.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text('No complaints yet.',
                            style: AppStyles.subtitle),
                      ),
                    );
                  }

                  return Column(
                    children: provider.complaints.take(3).map((complaint) {
                      return ComplaintCard(
                        complaint: complaint,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.complaintDetail,
                          arguments: complaint.id,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String count, String sublabel, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppStyles.caption),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text( count,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(sublabel, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
