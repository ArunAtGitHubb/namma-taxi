import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/map/presentation/screens/dashboard_screen.dart';
import '../../features/navigation/presentation/screens/trip_navigation_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/rides/presentation/screens/ride_details_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/wallet/domain/entities/wallet_entity.dart';
import '../../features/wallet/presentation/screens/payment_success_screen.dart';
import '../../features/wallet/presentation/screens/purchase_credits_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/ride/:id',
      builder: (context, state) => RideDetailsScreen(
        rideId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/trip',
      builder: (context, state) => const TripNavigationScreen(),
    ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: '/wallet/purchase',
      builder: (context, state) => const PurchaseCreditsScreen(),
    ),
    GoRoute(
      path: '/wallet/success',
      builder: (context, state) => PaymentSuccessScreen(
        plan: state.extra as CreditPlan?,
      ),
    ),
    GoRoute(
      path: '/earnings',
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
