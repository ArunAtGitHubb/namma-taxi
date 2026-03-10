import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Appearance section
            _buildSectionHeader('Appearance')
                .animate()
                .fadeIn(duration: 400.ms),
            AppCard(
              child: Column(
                children: [
                  _buildThemeOption(
                    context: context,
                    ref: ref,
                    title: 'System',
                    subtitle: 'Follow system theme',
                    icon: Icons.brightness_auto,
                    value: ThemeMode.system,
                    groupValue: themeMode,
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    context: context,
                    ref: ref,
                    title: 'Light',
                    subtitle: 'Always use light theme',
                    icon: Icons.light_mode_outlined,
                    value: ThemeMode.light,
                    groupValue: themeMode,
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    context: context,
                    ref: ref,
                    title: 'Dark',
                    subtitle: 'Always use dark theme',
                    icon: Icons.dark_mode_outlined,
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // Notifications section
            _buildSectionHeader('Notifications')
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
            AppCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Ride Requests',
                    subtitle: 'Get notified for new ride requests',
                    icon: Icons.local_taxi_outlined,
                    value: true,
                    onChanged: (_) {},
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Credit Alerts',
                    subtitle: 'Alert when credits are low',
                    icon: Icons.warning_amber_outlined,
                    value: true,
                    onChanged: (_) {},
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Payment Updates',
                    subtitle: 'Confirmation for payments',
                    icon: Icons.payment_outlined,
                    value: true,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // Map section
            _buildSectionHeader('Map')
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms),
            AppCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Auto-track Location',
                    subtitle: 'Track location while online',
                    icon: Icons.gps_fixed,
                    value: true,
                    onChanged: (_) {},
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Show Traffic',
                    subtitle: 'Display traffic layer on map',
                    icon: Icons.traffic_outlined,
                    value: false,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // About section
            _buildSectionHeader('About')
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms),
            AppCard(
              child: Column(
                children: [
                  _buildInfoTile(
                    title: 'Version',
                    value: '1.0.0',
                    icon: Icons.info_outline,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    title: 'Terms of Service',
                    icon: Icons.description_outlined,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    title: 'Privacy Policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.grey500,
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode groupValue,
  }) {
    final isSelected = value == groupValue;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.grey500,
      ),
      title: Text(title, style: AppTextStyles.titleSmall),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
      ),
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.primary : AppColors.grey400,
      ),
      onTap: () => ref.read(themeModeProvider.notifier).state = value,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey600),
      title: Text(title, style: AppTextStyles.titleSmall),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required IconData icon,
    String? value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey600),
      title: Text(title, style: AppTextStyles.titleSmall),
      trailing: value != null
          ? Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            )
          : const Icon(Icons.chevron_right, color: AppColors.grey400),
      onTap: onTap,
    );
  }
}
