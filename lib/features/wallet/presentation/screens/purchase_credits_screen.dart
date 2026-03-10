import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/wallet_entity.dart';
import '../providers/wallet_provider.dart';

class PurchaseCreditsScreen extends ConsumerStatefulWidget {
  const PurchaseCreditsScreen({super.key});

  @override
  ConsumerState<PurchaseCreditsScreen> createState() =>
      _PurchaseCreditsScreenState();
}

class _PurchaseCreditsScreenState extends ConsumerState<PurchaseCreditsScreen> {
  CreditPlan? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Credits'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose a Plan',
                    style: AppTextStyles.headlineSmall,
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Select the plan that fits your driving needs',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
                  const SizedBox(height: 24),
                  ...CreditPlan.defaultPlans.asMap().entries.map(
                        (entry) => _buildPlanCard(entry.value)
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 200 + entry.key * 150),
                              duration: 500.ms,
                            )
                            .slideX(begin: 0.1),
                      ),
                ],
              ),
            ),
          ),
          _buildBottomBar(wallet.isLoading),
        ],
      ),
    );
  }

  Widget _buildPlanCard(CreditPlan plan) {
    final isSelected = _selectedPlan?.id == plan.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (plan.isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'POPULAR',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.grey900,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.priceInDollars.asCurrency,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${plan.credits} credits',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bolt,
                    size: 16,
                    color: isSelected ? AppColors.primaryDark : AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.pricePerCredit.toStringAsFixed(2)}/credit',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.primaryDark : AppColors.grey600,
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

  Widget _buildBottomBar(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton(
          label: _selectedPlan != null
              ? 'Pay ${_selectedPlan!.priceInDollars.asCurrency}'
              : 'Select a plan',
          onPressed: _selectedPlan != null ? () => _onPurchase() : null,
          isLoading: isLoading,
        ),
      ),
    );
  }

  Future<void> _onPurchase() async {
    if (_selectedPlan == null) return;

    final success = await ref
        .read(walletProvider.notifier)
        .purchaseCredits(_selectedPlan!);

    if (!mounted) return;

    if (success) {
      context.go('/wallet/success', extra: _selectedPlan);
    } else {
      context.showSnackBar('Payment failed. Please try again.', isError: true);
    }
  }
}
