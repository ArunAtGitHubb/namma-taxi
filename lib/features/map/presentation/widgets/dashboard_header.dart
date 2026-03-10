import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../driver_status/presentation/widgets/online_toggle_button.dart';

class DashboardHeader extends StatelessWidget {
  final int credits;
  final bool isOnline;
  final DateTime? onlineSince;
  final VoidCallback onMenuTap;
  final VoidCallback onWalletTap;
  final VoidCallback onEarningsTap;

  const DashboardHeader({
    super.key,
    required this.credits,
    required this.isOnline,
    this.onlineSince,
    required this.onMenuTap,
    required this.onWalletTap,
    required this.onEarningsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.black.withValues(alpha: 0.7),
            AppColors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Profile button
          _buildCircleButton(
            icon: Icons.person,
            onTap: onMenuTap,
          ),
          const SizedBox(width: 12),

          // Earnings button
          _buildCircleButton(
            icon: Icons.bar_chart_rounded,
            onTap: onEarningsTap,
          ),

          const Spacer(),

          // Online toggle
          const OnlineToggleButton(),

          const Spacer(),

          // Wallet credits badge
          GestureDetector(
            onTap: onWalletTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: credits > 0
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt,
                    color: credits > 0 ? AppColors.primary : AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$credits',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: credits > 0 ? AppColors.primary : AppColors.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
                .animate(
                  target: credits <= 3 && credits > 0 ? 1 : 0,
                  onPlay: (c) {
                    if (credits <= 3 && credits > 0) c.repeat(reverse: true);
                  },
                )
                .scaleXY(begin: 1.0, end: 1.05, duration: 800.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(icon, color: AppColors.white, size: 20),
      ),
    );
  }
}
