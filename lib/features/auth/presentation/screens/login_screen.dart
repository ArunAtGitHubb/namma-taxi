import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUp = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onGoogleSignIn() {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  void _onEmailAuth() {
    if (!_formKey.currentState!.validate()) return;

    if (_isSignUp) {
      ref.read(authProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
    } else {
      ref.read(authProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, state) {
      if (state.status == AuthStatus.authenticated) {
        context.go('/dashboard');
      } else if (state.status == AuthStatus.error && state.errorMessage != null) {
        context.showSnackBar(state.errorMessage!, isError: true);
      }
    });

    final isLoading = authState.status == AuthStatus.loading;

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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildHeader().animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                const SizedBox(height: 48),
                _buildGoogleButton(isLoading)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 24),
                _buildDivider()
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms),
                const SizedBox(height: 24),
                _buildEmailForm(isLoading)
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 16),
                _buildToggleAuthMode()
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_taxi_rounded,
            size: 44,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Driver',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to start earning',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.grey400,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : _onGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.grey700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(2),
              child: const Text(
                'G',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: AppTextStyles.button.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.grey700)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.grey700)),
      ],
    );
  }

  Widget _buildEmailForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_isSignUp) ...[
            TextFormField(
              controller: _nameController,
              validator: (v) => Validators.required(v, 'Name'),
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Full Name',
                hintStyle: TextStyle(color: AppColors.grey500),
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.grey500),
                filled: true,
                fillColor: AppColors.darkCard,
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _emailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Email address',
              hintStyle: TextStyle(color: AppColors.grey500),
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.grey500),
              filled: true,
              fillColor: AppColors.darkCard,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            validator: Validators.password,
            obscureText: _obscurePassword,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(color: AppColors.grey500),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey500),
              filled: true,
              fillColor: AppColors.darkCard,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey500,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: _isSignUp ? 'Create Account' : 'Sign In',
            onPressed: isLoading ? null : _onEmailAuth,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleAuthMode() {
    return TextButton(
      onPressed: () => setState(() => _isSignUp = !_isSignUp),
      child: RichText(
        text: TextSpan(
          text: _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey400),
          children: [
            TextSpan(
              text: _isSignUp ? 'Sign In' : 'Sign Up',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
