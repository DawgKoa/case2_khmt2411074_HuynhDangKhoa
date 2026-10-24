import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';
import 'brutalist_badge.dart';

class BrutalistTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onStatusTap;

  const BrutalistTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(now) &&
        task.status != 'completed';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.primaryInk, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primaryInk,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Status badge & Priority badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onStatusTap,
                  child: _buildStatusBadge(task.status),
                ),
                _buildPriorityBadge(task.priority),
              ],
            ),
            const SizedBox(height: 12),

            // Task Title
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryInk,
                height: 1.25,
              ),
            ),

            // Task Description (if any)
            if (task.description.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Divider line (Nivora Industrial style)
            Container(
              height: 1.5,
              color: AppColors.divider.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),

            // Footer Row: Due Date & Assignees / Creator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Due date
                if (task.dueDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: isOverdue ? AppColors.danger : AppColors.secondaryText,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('dd/MM/yyyy').format(task.dueDate!),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isOverdue ? AppColors.danger : AppColors.secondaryText,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: AppColors.primaryInk, width: 1),
                          ),
                          child: Text(
                            'QUÁ HẠN',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Text(
                    'KHÔNG CÓ HẠN',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryText,
                    ),
                  ),

                // Creator / Assignee info
                _buildAssigneeBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'in_progress':
        return BrutalistBadge(
          text: 'ĐANG LÀM',
          backgroundColor: AppColors.primaryAccent,
          textColor: AppColors.primaryInk,
          icon: Icons.sync,
        );
      case 'completed':
        return BrutalistBadge(
          text: 'HOÀN THÀNH',
          backgroundColor: const Color(0xFF9AE6B4),
          textColor: AppColors.primaryInk,
          icon: Icons.check_circle_outline,
        );
      case 'cancelled':
        return BrutalistBadge(
          text: 'ĐÃ HỦY',
          backgroundColor: AppColors.danger,
          textColor: Colors.white,
          icon: Icons.cancel_outlined,
        );
      case 'todo':
      default:
        return BrutalistBadge(
          text: 'CHỜ XỬ LÝ',
          backgroundColor: AppColors.secondarySurface,
          textColor: AppColors.primaryInk,
          icon: Icons.hourglass_empty,
        );
    }
  }

  Widget _buildPriorityBadge(String priority) {
    switch (priority) {
      case 'high':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primaryInk, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.priority_high, size: 12, color: Colors.white),
              const SizedBox(width: 2),
              Text(
                'ƯU TIÊN CAO',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      case 'medium':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primaryInk, width: 1.5),
          ),
          child: Text(
            'TRUNG BÌNH',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryInk,
            ),
          ),
        );
      case 'low':
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primaryInk, width: 1.5),
          ),
          child: Text(
            'THẤP',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryInk,
            ),
          ),
        );
    }
  }

  Widget _buildAssigneeBadge() {
    final name = task.primaryAssignee?.fullName ??
        (task.assignees.isNotEmpty ? task.assignees.first.fullName : task.createdBy?.fullName);

    if (name == null || name.isEmpty) {
      return const SizedBox.shrink();
    }

    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryInk, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryInk,
            ),
          ),
        ),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryInk,
            ),
          ),
        ),
      ],
    );
  }
}
