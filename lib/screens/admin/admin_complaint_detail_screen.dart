import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/helpers.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../user/complaint_detail_screen.dart';
import '../common/chat_screen.dart';

class AdminComplaintDetailScreen extends StatefulWidget {
  final String complaintId;

  const AdminComplaintDetailScreen({super.key, required this.complaintId});

  @override
  State<AdminComplaintDetailScreen> createState() =>
      _AdminComplaintDetailScreenState();
}

class _AdminComplaintDetailScreenState
    extends State<AdminComplaintDetailScreen> {
  final _responseController = TextEditingController();
  String? _selectedStatus;
  bool _isLoading = false;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate(ComplaintModel complaint) async {
    if (_selectedStatus == null && _responseController.text.isEmpty) {
      Helpers.showSnackBar(context, 'No changes to submit', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final complaintProvider =
          Provider.of<ComplaintProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);

      // Update status if changed
      if (_selectedStatus != null && _selectedStatus != complaint.status) {
        await complaintProvider.updateStatus(
          complaint.id,
          _selectedStatus!,
          'Status updated by ${auth.user?.name}',
        );
      }

      // Add response if provided
      if (_responseController.text.trim().isNotEmpty) {
        await complaintProvider.addResponse(
          complaint.id,
          AdminResponse(
            message: _responseController.text.trim(),
            respondedBy: auth.user?.name ?? 'Admin',
            respondedByTitle: 'Compliance Officer',
            respondedAt: DateTime.now(),
            verified: true,
          ),
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
        _responseController.clear();
        Helpers.showSnackBar(context, AppStrings.statusUpdated);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showSnackBar(context, 'Update failed: $e', isError: true);
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: const Text(
            'Are you sure you want to permanently delete this complaint? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final complaintProvider =
            Provider.of<ComplaintProvider>(context, listen: false);
        await complaintProvider.deleteComplaint(widget.complaintId);
        if (mounted) {
          Helpers.showSnackBar(context, 'Complaint deleted');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          Helpers.showSnackBar(context, 'Delete failed: $e', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Admin Review',
            style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _handleDelete,
            tooltip: 'Delete Complaint',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .doc(widget.complaintId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64,
                      color: AppColors.error.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('Failed to load complaint',
                      style: AppStyles.subtitleOf(context)),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Complaint not found or deleted',
                      style: AppStyles.subtitleOf(context)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final complaint = ComplaintModel.fromJson(
            snapshot.data!.data() as Map<String, dynamic>,
            id: snapshot.data!.id,
          );

          // Initialize selected status from complaint if not set
          _selectedStatus ??= complaint.status;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Reusable complaint detail content (no nested Scaffold)
                ComplaintDetailContent(complaint: complaint),

                // Chat button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(complaint: complaint)),
                    ),
                    icon: const Icon(Icons.forum_outlined),
                    label: const Text('Open Discussion'),
                    style: AppStyles.outlinedButtonStyle,
                  ),
                ),
                const SizedBox(height: 24),

                // Admin Controls Section
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: AppStyles.cardDecorationOf(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.updateStatus,
                          style: AppStyles.labelLargeOf(context)),
                      const SizedBox(height: 12),
                      _buildStatusSelector(complaint),
                      const SizedBox(height: 24),
                      Text(AppStrings.respondToComplaint,
                          style: AppStyles.labelLargeOf(context)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: '',
                        hint: AppStrings.writeResponse,
                        controller: _responseController,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: AppStrings.submitResponse,
                        isLoading: _isLoading,
                        onPressed: () => _handleUpdate(complaint),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusSelector(ComplaintModel complaint) {
    return Row(
      children: [
        _statusChip('pending', AppColors.pending),
        const SizedBox(width: 8),
        _statusChip('in_progress', AppColors.inProgress),
        const SizedBox(width: 8),
        _statusChip('resolved', AppColors.resolved),
      ],
    );
  }

  Widget _statusChip(String status, Color color) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          status.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
