import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../navigation/presentation/providers/trip_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../domain/entities/ride_entity.dart';
import '../providers/rides_provider.dart';

class RideDetailsScreen extends ConsumerWidget {
  final String rideId;

  const RideDetailsScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesState = ref.watch(ridesProvider);
    final walletState = ref.watch(walletProvider);
    final ride = ridesState.selectedRide ??
        ridesState.availableRides.where((r) => r.id == rideId).firstOrNull;

    if (ride == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Ride not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRouteCard(ride)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.1),
                  const SizedBox(height: 16),
                  _buildDetailsGrid(ride)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 16),
                  _buildEarningsCard(ride)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideY(begin: 0.1),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, ref, ride, walletState.hasCredits, ridesState.isLoading),
        ],
      ),
    );
  }

  Widget _buildRouteCard(RideEntity ride) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildLocationRow(
            icon: Icons.trip_origin,
            iconColor: AppColors.success,
            label: 'PICKUP',
            address: ride.pickupAddress,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              children: List.generate(
                3,
                (_) => Container(
                  width: 2,
                  height: 6,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: AppColors.grey600,
                ),
              ),
            ),
          ),
          _buildLocationRow(
            icon: Icons.location_on,
            iconColor: AppColors.error,
            label: 'DROP OFF',
            address: ride.dropAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.grey500,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(RideEntity ride) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem(
            icon: Icons.straighten,
            label: 'Distance',
            value: '${ride.distanceKm.toStringAsFixed(1)} km',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailItem(
            icon: Icons.access_time,
            label: 'Est. Time',
            value: '${ride.estimatedMinutes} min',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailItem(
            icon: Icons.person_outline,
            label: 'Passenger',
            value: ride.passengerName ?? 'N/A',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.grey600, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleSmall,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(RideEntity ride) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Estimated Earnings',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.grey900.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ride.estimatedEarnings.asCurrency,
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.grey900,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Costs 1 credit to accept',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey900.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    RideEntity ride,
    bool hasCredits,
    bool isLoading,
  ) {
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
          label: hasCredits ? 'Accept Ride' : 'Insufficient Credits',
          icon: hasCredits ? Icons.check_circle : Icons.warning_amber,
          onPressed: hasCredits
              ? () => _onAcceptRide(context, ref, ride.id)
              : () => _showInsufficientCreditsDialog(context),
          isLoading: isLoading,
          variant: hasCredits ? AppButtonVariant.primary : AppButtonVariant.secondary,
        ),
      ),
    );
  }

  Future<void> _onAcceptRide(
    BuildContext context,
    WidgetRef ref,
    String rideId,
  ) async {
    final ridesState = ref.read(ridesProvider);
    final ride = ridesState.selectedRide ??
        ridesState.availableRides.where((r) => r.id == rideId).firstOrNull;

    final success = await ref.read(ridesProvider.notifier).acceptRide(rideId);

    if (success) {
      ref.read(walletProvider.notifier).deductCredit();
      if (ride != null) {
        ref.read(tripProvider.notifier).startTrip(ride);
      }
      if (context.mounted) {
        context.go('/trip');
      }
    } else {
      if (context.mounted) {
        context.showSnackBar('Failed to accept ride.', isError: true);
      }
    }
  }

  void _showInsufficientCreditsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 8),
            Text('Insufficient Credits', style: AppTextStyles.titleMedium),
          ],
        ),
        content: Text(
          'You need at least 1 credit to accept a ride. '
          'Please purchase credits to continue.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/wallet/purchase');
            },
            child: const Text('Buy Credits'),
          ),
        ],
      ),
    );
  }
}
