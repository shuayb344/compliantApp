import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/complaint_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).fetchComplaints();
    });
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;
    
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.userHome); // Admin can see user home too
        break;
      case 1:
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.adminNotifications);
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
    final complaintProvider = Provider.of<ComplaintProvider>(context);

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
              user?.name[0].toUpperCase() ?? 'A',
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
            icon: const Icon(Icons.bar_chart_outlined, color: AppColors.primary),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.adminAnalytics),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
        isAdmin: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ComplaintProvider>(context, listen: false)
              .fetchComplaints();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.executiveOverview, style: AppStyles.heading2),
              const SizedBox(height: 4),
              Text(AppStrings.executiveOverviewSubtitle,
                  style: AppStyles.bodySmall),
              const SizedBox(height: 24),

              // Info Grid
              _buildStatsGrid(complaintProvider),
              const SizedBox(height: 32),

              // Category Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                        'All', complaintProvider.selectedCategory == 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Billing',
                        complaintProvider.selectedCategory == 'Billing'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Technical',
                        complaintProvider.selectedCategory == 'Technical'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Service',
                        complaintProvider.selectedCategory == 'Service'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                onChanged: (v) => complaintProvider.setSearchQuery(v),
                decoration: AppStyles.inputDecoration(
                  label: '',
                  hint: AppStrings.searchComplaints,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 24),

              // Complaints List
              if (complaintProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ...complaintProvider.filteredComplaints.map((complaint) {
                  return ComplaintCard(
                    complaint: complaint,
                    isAdminView: true,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.adminComplaintDetail,
                      arguments: complaint.id,
                    ),
                  );
                }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ComplaintProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(AppStrings.total, provider.totalCount.toString(), Icons.insert_chart_outlined, badge: '+12%'),
            const SizedBox(width: 16),
            _buildStatCard(AppStrings.pendingLabel, provider.pendingCount.toString(), Icons.assignment_outlined, hasDot: true),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(AppStrings.inProgressLabel, provider.inProgressCount.toString(), Icons.refresh),
            const SizedBox(width: 16),
            _buildStatCard(AppStrings.resolvedLabel, provider.resolvedCount.toString(), Icons.check_circle_outline),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {String? badge, bool hasDot = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 20, color: AppColors.primary.withValues(alpha: 0.6)),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
                    child: Text(badge, style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                else if (hasDot)
                  const Icon(Icons.circle, color: AppColors.pending, size: 8),
              ],
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) Provider.of<ComplaintProvider>(context, listen: false).setCategory(label);
      },
      selectedColor: AppColors.primary,
      disabledColor: Colors.white,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider)),
      showCheckmark: false,
    );
  }
}
