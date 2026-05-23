import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/complaint_card.dart';

class ComplaintsHistoryScreen extends StatefulWidget {
  const ComplaintsHistoryScreen({super.key});

  @override
  State<ComplaintsHistoryScreen> createState() => _ComplaintsHistoryScreenState();
}

class _ComplaintsHistoryScreenState extends State<ComplaintsHistoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);

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
          'My Complaints',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Filter and Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            color: Colors.white,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', complaintProvider.selectedCategory == 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Billing', complaintProvider.selectedCategory == 'Billing'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Technical', complaintProvider.selectedCategory == 'Technical'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Service', complaintProvider.selectedCategory == 'Service'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => complaintProvider.setSearchQuery(v),
                  decoration: AppStyles.inputDecoration(
                    label: '',
                    hint: 'Search by ID or title...',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),

          // Complaints List
          Expanded(
            child: Consumer<ComplaintProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final complaints = provider.filteredComplaints;

                if (complaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64,
                            color: AppColors.textHint.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text('No matches found.', style: AppStyles.subtitle),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final user =
                        Provider.of<AuthProvider>(context, listen: false).user;
                    if (user != null) {
                      await provider.fetchComplaints(userId: user.uid);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      return ComplaintCard(
                        complaint: complaints[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.complaintDetail,
                          arguments: complaints[index].id,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
      ),
      showCheckmark: false,
    );
  }
}
