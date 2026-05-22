import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../models/complaint_model.dart';

class StatusTimeline extends StatelessWidget {
  final List<StatusHistoryEntry> history;

  const StatusTimeline({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // Show most recent first
    final sortedHistory = List<StatusHistoryEntry>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      children: List.generate(sortedHistory.length, (index) {
        final entry = sortedHistory[index];
        final isFirst = index == 0;
        final isLast = index == sortedHistory.length - 1;
        final color = Helpers.getStatusColor(entry.status);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line and dot
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    // Top line
                    if (!isFirst)
                      Container(
                        width: 2,
                        height: 8,
                        color: AppColors.divider,
                      ),
                    // Dot
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    // Bottom line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.divider,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Helpers.getStatusText(entry.status),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          Text(
                            Helpers.formatDateWithTime(entry.timestamp),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.note,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
