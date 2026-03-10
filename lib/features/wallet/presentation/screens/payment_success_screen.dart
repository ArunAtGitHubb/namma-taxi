import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/wallet_entity.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final CreditPlan? plan;

  const PaymentSuccessScreen({super.key, this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.5, 0.5)),
              const SizedBox(height: 32),
              Text(
                'Payment Successful!',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
              const SizedBox(height: 12),
              Text(
                plan != null
                    ? '${plan!.credits} credits have been added to your wallet'
                    : 'Credits have been added to your wallet',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
              if (plan != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        plan!.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+${plan!.credits}',
                        style: AppTextStyles.credit.copyWith(fontSize: 48),
                      ),
                      Text(
                        'credits added',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2),
              ],
              const Spacer(),
              AppButton(
                label: 'Go to Dashboard',
                onPressed: () => context.go('/dashboard'),
              ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
              const SizedBox(height: 12),
              AppButton(
                label: 'View Wallet',
                variant: AppButtonVariant.outline,
                onPressed: () => context.go('/wallet'),
              ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
