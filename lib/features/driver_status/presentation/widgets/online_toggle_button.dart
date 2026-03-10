import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/driver_status_provider.dart';

class OnlineToggleButton extends ConsumerWidget {
  const OnlineToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(driverStatusProvider);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ref.read(driverStatusProvider.notifier).toggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: status.isToggling
              ? AppColors.grey600
              : status.isOnline
                  ? AppColors.success
                  : AppColors.grey700,
          borderRadius: BorderRadius.circular(28),
          boxShadow: status.isOnline
              ? [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status.isToggling)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: status.isOnline ? AppColors.white : AppColors.grey400,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(
                    target: status.isOnline ? 1 : 0,
                    onPlay: (c) {
                      if (status.isOnline) c.repeat(reverse: true);
                    },
                  )
                  .scaleXY(begin: 1.0, end: 1.3, duration: 1200.ms),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                status.isToggling
                    ? 'Switching...'
                    : status.isOnline
                        ? 'Online'
                        : 'Go Online',
                key: ValueKey(status.isOnline),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Large center-screen toggle for initial go-online flow
class LargeOnlineToggle extends ConsumerWidget {
  const LargeOnlineToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(driverStatusProvider);

    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        ref.read(driverStatusProvider.notifier).toggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: status.isOnline ? AppColors.success : AppColors.grey700,
          boxShadow: [
            BoxShadow(
              color: (status.isOnline ? AppColors.success : AppColors.grey700)
                  .withValues(alpha: 0.3),
              blurRadius: 32,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (status.isToggling)
              const CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 3,
              )
            else ...[
              Icon(
                status.isOnline ? Icons.power_settings_new : Icons.power_settings_new,
                color: AppColors.white,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                status.isOnline ? 'ONLINE' : 'GO ONLINE',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
