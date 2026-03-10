import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.checkAuthStatus();

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.secondary, AppColors.darkBackground],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_taxi_rounded,
                size: 64,
                color: AppColors.grey900,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.5, 0.5)),
            const SizedBox(height: 32),
            Text(
              'Namma Taxi',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(
                  begin: 0.3,
                  end: 0,
                ),
            const SizedBox(height: 8),
            Text(
              'Driver App',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
            const SizedBox(height: 60),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
