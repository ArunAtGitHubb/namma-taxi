import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final walletState = ref.watch(walletProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar & Name
            Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(
                          user?.name.initials ?? 'D',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.grey900,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Driver',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 8),
                if (user?.isVerified == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Driver',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 32),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.bolt,
                      value: '${walletState.credits}',
                      label: 'Credits',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_taxi,
                      value: '—',
                      label: 'Rides',
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.star,
                      value: '—',
                      label: 'Rating',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

            const SizedBox(height: 24),

            // Menu items
            _buildMenuItem(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update your name and phone',
              onTap: () => context.push('/profile/edit'),
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideX(begin: 0.05),

            _buildMenuItem(
              icon: Icons.upload_file_outlined,
              title: 'Upload Documents',
              subtitle: 'License, vehicle, insurance',
              onTap: () => context.push('/profile/documents'),
            ).animate().fadeIn(delay: 275.ms, duration: 400.ms).slideX(begin: 0.05),

            _buildMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet',
              subtitle: '${walletState.credits} credits available',
              onTap: () => context.push('/wallet'),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: 0.05),

            _buildMenuItem(
              icon: Icons.history,
              title: 'Ride History',
              subtitle: 'View your past rides',
              onTap: () {},
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideX(begin: 0.05),

            _buildMenuItem(
              icon: Icons.bar_chart_rounded,
              title: 'Earnings',
              subtitle: 'Track your earnings',
              onTap: () => context.push('/earnings'),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideX(begin: 0.05),

            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get assistance',
              onTap: () {},
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideX(begin: 0.05),

            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version 1.0.0',
              onTap: () {},
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms).slideX(begin: 0.05),

            const SizedBox(height: 16),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    'Logout',
                    style: AppTextStyles.button.copyWith(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.grey700, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey400),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: AppTextStyles.titleMedium),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
