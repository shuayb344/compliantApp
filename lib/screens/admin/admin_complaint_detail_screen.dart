import 'package:flutter/material.dart';
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
  final ComplaintModel complaint;

  const AdminComplaintDetailScreen({super.key, required this.complaint});

  @override
  State<AdminComplaintDetailScreen> createState() => _AdminComplaintDetailScreenState();
}

class _AdminComplaintDetailScreenState extends State<AdminComplaintDetailScreen> {
  final _responseController = TextEditingController();
  String _selectedStatus = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.complaint.status;
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);
    
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Update status
    if (_selectedStatus != widget.complaint.status) {
      await complaintProvider.updateStatus(
        widget.complaint.id, 
        _selectedStatus, 
        'Status updated by ${auth.user?.name}'
      );
    }

    // Add response
    if (_responseController.text.isNotEmpty) {
      await complaintProvider.addResponse(
        widget.complaint.id,
        AdminResponse(
          message: _responseController.text,
          respondedBy: auth.user?.name ?? 'Admin',
          respondedByTitle: 'Compliance Officer',
          respondedAt: DateTime.now(),
          verified: true,
        ),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      Helpers.showSnackBar(context, 'Update successful');
      Navigator.pop(context);
    }
  }

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
        title: const Text('Admin Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.forum_outlined, color: AppColors.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(complaint: widget.complaint)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.primary),
            onPressed: _handleUpdate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Re-use User's detail view as a base
            ComplaintDetailScreen(complaint: widget.complaint),

            // Admin Controls Section
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(AppStrings.updateStatus, style: AppStyles.labelLarge),
                  const SizedBox(height: 12),
                  _buildStatusSelector(),
                  const SizedBox(height: 24),
                  const Text(AppStrings.respondToComplaint, style: AppStyles.labelLarge),
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
                    onPressed: _handleUpdate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
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
