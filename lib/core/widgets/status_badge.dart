import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
  });

  factory StatusBadge.active({String label = 'Active'}) => StatusBadge(
        label: label,
        color: AppColors.success.withValues(alpha: 0.15),
        textColor: AppColors.success,
        icon: Icons.check_circle_outline,
      );

  factory StatusBadge.inactive({String label = 'Inactive'}) => StatusBadge(
        label: label,
        color: AppColors.grey400.withValues(alpha: 0.15),
        textColor: AppColors.grey600,
        icon: Icons.pause_circle_outline,
      );

  factory StatusBadge.warning({String label = 'Low Credits'}) => StatusBadge(
        label: label,
        color: AppColors.warning.withValues(alpha: 0.15),
        textColor: AppColors.warning,
        icon: Icons.warning_amber_rounded,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor ?? AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
