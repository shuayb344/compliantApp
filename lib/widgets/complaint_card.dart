import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/utils/helpers.dart';
import '../models/complaint_model.dart';
import 'status_badge.dart';

/// Complaint card for the USER home screen (simpler layout)
class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback? onTap;
  final bool isAdminView;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.onTap,
    this.isAdminView = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdminView) {
      return _buildAdminCard(context);
    }
    return _buildUserCard(context);
  }

  Widget _buildUserCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.cardDecorationFlat,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ref ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REF #${complaint.refId}',
                  style: AppStyles.refId,
                ),
                StatusBadge(status: complaint.status),
              ],
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              complaint.title,
              style: AppStyles.cardTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Description
            Text(
              complaint.description,
              style: AppStyles.cardDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // Date and pending info
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  Helpers.formatDateShort(complaint.createdAt),
                  style: AppStyles.bodySmall,
                ),
                const Spacer(),
                if (complaint.status == 'pending')
                  Text(
                    Helpers.getDaysPending(complaint.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.pending,
                    ),
                  )
                else if (complaint.status == 'in_progress')
                  Text(
                    'Under review',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Icon(Icons.check_circle_outline,
                      size: 18, color: AppColors.resolved),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.cardDecorationFlat,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceLight,
              child: Text(
                complaint.userName.isNotEmpty
                    ? complaint.userName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Ref
                  Row(
                    children: [
                      Text(
                        complaint.userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• #${complaint.refId}',
                        style: AppStyles.refId,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Description
                  Text(
                    complaint.description,
                    style: AppStyles.cardDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Status, date, category
                  Row(
                    children: [
                      StatusBadge(status: complaint.status, compact: true),
                      const SizedBox(width: 10),
                      Text(
                        Helpers.formatDateShort(complaint.createdAt),
                        style: AppStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Category chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      complaint.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Helpers.getCategoryColor(complaint.category),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
