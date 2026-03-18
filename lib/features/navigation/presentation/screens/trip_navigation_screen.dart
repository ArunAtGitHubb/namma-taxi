import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../services/mapbox_service.dart';
import '../../../earnings/presentation/providers/earnings_provider.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../map/presentation/widgets/map_cluster_manager.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../domain/entities/trip_state.dart';
import '../providers/trip_provider.dart';
import '../widgets/turn_instruction_bar.dart';

class TripNavigationScreen extends ConsumerStatefulWidget {
  const TripNavigationScreen({super.key});

  @override
  ConsumerState<TripNavigationScreen> createState() =>
      _TripNavigationScreenState();
}

class _TripNavigationScreenState extends ConsumerState<TripNavigationScreen> {
  final _clusterManager = MapClusterManager();

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripProvider);
    final mapState = ref.watch(mapProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          MapWidget(
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  mapState.currentLocation?.longitude ?? 77.5946,
                  mapState.currentLocation?.latitude ?? 12.9716,
                ),
              ),
              zoom: 15.0,
            ),
            styleUri: MapboxService.styleUrlDark,
            onMapCreated: _onMapCreated,
          ),

          // Top bar with back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(trip),
          ),

          // Turn-by-turn instruction
          if (trip.currentStep != null &&
              (trip.phase == TripPhase.navigatingToPickup ||
                  trip.phase == TripPhase.inTrip))
            Positioned(
              top: MediaQuery.paddingOf(context).top + 60,
              left: 16,
              right: 16,
              child: TurnInstructionBar(step: trip.currentStep!)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.3),
            ),

          // Bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(trip),
          ),

          // Loading
          if (trip.isLoading)
            Container(
              color: AppColors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _clusterManager.attach(mapboxMap);

    await Future.delayed(const Duration(milliseconds: 500));
    await _clusterManager.initializeSources();

    _drawRoutes();
  }

  void _drawRoutes() async {
    final trip = ref.read(tripProvider);

    if (trip.pickupRoute != null) {
      await _clusterManager.showPickupRoute(trip.pickupRoute!.coordinates);
    }
    if (trip.tripRoute != null) {
      await _clusterManager.showTripRoute(trip.tripRoute!.coordinates);
    }

    // Fit bounds to show the route
    final ride = trip.ride;
    if (ride != null) {
      final driverLoc = ref.read(mapProvider).currentLocation;
      if (driverLoc != null) {
        final allLats = [
          driverLoc.latitude,
          ride.pickupLocation.latitude,
          ride.dropLocation.latitude,
        ];
        final allLngs = [
          driverLoc.longitude,
          ride.pickupLocation.longitude,
          ride.dropLocation.longitude,
        ];

        allLats.sort();
        allLngs.sort();

        await _clusterManager.fitBounds(
          southWestLat: allLats.first,
          southWestLng: allLngs.first,
          northEastLat: allLats.last,
          northEastLng: allLngs.last,
        );
      }
    }
  }

  Widget _buildTopBar(TripState trip) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showCancelDialog(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: AppColors.white, size: 20),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _phaseColor(trip.phase).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _phaseColor(trip.phase).withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              _phaseLabel(trip.phase),
              style: AppTextStyles.labelMedium.copyWith(
                color: _phaseColor(trip.phase),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(TripState trip) {
    final activeRoute = trip.activeRoute;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Route info
              if (activeRoute != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRouteInfoItem(
                      Icons.straighten,
                      activeRoute.formattedDistance,
                      'Distance',
                    ),
                    Container(width: 1, height: 40, color: AppColors.grey200),
                    _buildRouteInfoItem(
                      Icons.access_time,
                      activeRoute.formattedDuration,
                      'ETA',
                    ),
                    Container(width: 1, height: 40, color: AppColors.grey200),
                    _buildRouteInfoItem(
                      Icons.navigation,
                      '${activeRoute.steps.length}',
                      'Steps',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Destination info
              if (trip.ride != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        trip.phase == TripPhase.navigatingToPickup
                            ? Icons.trip_origin
                            : Icons.location_on,
                        color: trip.phase == TripPhase.navigatingToPickup
                            ? AppColors.success
                            : AppColors.error,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.phase == TripPhase.navigatingToPickup
                                  ? 'Heading to pickup'
                                  : trip.phase == TripPhase.inTrip
                                      ? 'Heading to drop-off'
                                      : 'Waiting for passenger',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.grey500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trip.phase == TripPhase.inTrip
                                  ? trip.ride!.dropAddress
                                  : trip.ride!.pickupAddress,
                              style: AppTextStyles.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (trip.ride != null)
                        Text(
                          trip.ride!.estimatedEarnings.asCurrency,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Action button
              _buildActionButton(trip),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, curve: Curves.easeOutCubic);
  }

  Widget _buildActionButton(TripState trip) {
    switch (trip.phase) {
      case TripPhase.navigatingToPickup:
        return AppButton(
          label: 'Arrived at Pickup',
          icon: Icons.check_circle,
          onPressed: () async {
            await ref.read(tripProvider.notifier).arrivedAtPickup();
            final err = ref.read(tripProvider).error;
            if (err != null && mounted) {
              context.showSnackBar(err, isError: true);
            }
          },
        );
      case TripPhase.waitingForPassenger:
        return AppButton(
          label: 'Start Trip',
          icon: Icons.play_arrow_rounded,
          onPressed: () async {
            await ref.read(tripProvider.notifier).beginTrip();
            _drawRoutes();
            final err = ref.read(tripProvider).error;
            if (err != null && mounted) {
              context.showSnackBar(err, isError: true);
            }
          },
          variant: AppButtonVariant.primary,
        );
      case TripPhase.inTrip:
        return AppButton(
          label: 'End Trip',
          icon: Icons.flag_rounded,
          onPressed: () async {
            await ref.read(tripProvider.notifier).completeTrip();
            final err = ref.read(tripProvider).error;
            if (err != null && mounted) {
              context.showSnackBar(err, isError: true);
            }
          },
          variant: AppButtonVariant.secondary,
        );
      case TripPhase.completed:
        return AppButton(
          label: 'Back to Dashboard',
          icon: Icons.home_rounded,
          onPressed: () {
            ref.read(walletProvider.notifier).loadBalance();
            ref.read(earningsProvider.notifier).loadEarnings();
            ref.read(tripProvider.notifier).clearTrip();
            context.go('/dashboard');
          },
        );
    }
  }

  Widget _buildRouteInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.grey600),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
        ),
      ],
    );
  }

  Color _phaseColor(TripPhase phase) {
    switch (phase) {
      case TripPhase.navigatingToPickup:
        return AppColors.info;
      case TripPhase.waitingForPassenger:
        return AppColors.warning;
      case TripPhase.inTrip:
        return AppColors.success;
      case TripPhase.completed:
        return AppColors.primary;
    }
  }

  String _phaseLabel(TripPhase phase) {
    switch (phase) {
      case TripPhase.navigatingToPickup:
        return 'Going to Pickup';
      case TripPhase.waitingForPassenger:
        return 'At Pickup';
      case TripPhase.inTrip:
        return 'Trip in Progress';
      case TripPhase.completed:
        return 'Trip Completed';
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Trip?', style: AppTextStyles.titleMedium),
        content: const Text(
            'Are you sure you want to cancel this trip? This may affect your rating.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Going'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(tripProvider.notifier).cancelTrip();
              if (mounted) context.go('/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Cancel Trip'),
          ),
        ],
      ),
    );
  }
}
