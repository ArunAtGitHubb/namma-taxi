import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/in_app_notification_banner.dart';
import '../../../../services/firebase_notification_service.dart';
import '../../../../services/mapbox_service.dart';
import '../../../../services/navigation_service.dart';
import '../../../driver_status/presentation/providers/driver_status_provider.dart';
import '../../../driver_status/presentation/widgets/online_toggle_button.dart';
import '../../../navigation/presentation/providers/trip_provider.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../../../rides/presentation/providers/realtime_rides_provider.dart';
import '../../../rides/presentation/providers/rides_provider.dart';
import '../../../rides/presentation/widgets/animated_ride_request_card.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/map_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/map_cluster_manager.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  MapboxMap? _mapboxMap;
  final _clusterManager = MapClusterManager();
  InAppNotification? _currentNotification;
  Timer? _notificationTimer;
  Timer? _markerUpdateTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_initialize);
  }

  Future<void> _initialize() async {
    ref.read(mapProvider.notifier).initializeLocation();
    ref.read(walletProvider.notifier).loadBalance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationTimer?.cancel();
    _markerUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncMapMarkers();
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _clusterManager.attach(mapboxMap);

    // Wait for style to load
    await Future.delayed(const Duration(milliseconds: 800));
    await _clusterManager.initializeSources();

    _loadNearbyRides();

    // Periodic marker sync every 30 seconds
    _markerUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _syncMapMarkers(),
    );
  }

  Future<void> _loadNearbyRides() async {
    final location = ref.read(mapProvider).currentLocation;
    if (location != null) {
      await ref.read(ridesProvider.notifier).loadAvailableRides(
            latitude: location.latitude,
            longitude: location.longitude,
          );
      _syncMapMarkers();
    }
  }

  void _syncMapMarkers() {
    final rides = ref.read(ridesProvider).availableRides;
    final loc = ref.read(mapProvider).currentLocation;

    _clusterManager.updateRideMarkers(rides);
    if (loc != null) {
      _clusterManager.updateDriverMarker(loc.latitude, loc.longitude, loc.heading);
    }
  }

  Future<void> _onRideTapped(RideEntity ride) async {
    ref.read(ridesProvider.notifier).selectRide(ride);

    // Show route preview
    final loc = ref.read(mapProvider).currentLocation;
    if (loc != null) {
      final navService = ref.read(navigationServiceProvider);
      final routes = await navService.getFullRoute(
        driverLat: loc.latitude,
        driverLng: loc.longitude,
        pickupLat: ride.pickupLocation.latitude,
        pickupLng: ride.pickupLocation.longitude,
        dropLat: ride.dropLocation.latitude,
        dropLng: ride.dropLocation.longitude,
      );

      if (routes.pickupRoute != null) {
        await _clusterManager.showPickupRoute(routes.pickupRoute!.coordinates);
      }
      if (routes.tripRoute != null) {
        await _clusterManager.showTripRoute(routes.tripRoute!.coordinates);
      }

      // Fit map to show everything
      final allLats = [
        loc.latitude,
        ride.pickupLocation.latitude,
        ride.dropLocation.latitude,
      ];
      final allLngs = [
        loc.longitude,
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

    if (mounted) context.push('/ride/${ride.id}');
  }

  Future<void> _acceptRide(RideEntity ride) async {
    final hasCredits = ref.read(walletProvider).hasCredits;
    if (!hasCredits) {
      _showInsufficientCreditsPopup();
      return;
    }

    // Try real-time first, fallback to REST
    final driverOnline = ref.read(driverStatusProvider).isOnline;
    bool success;
    if (driverOnline) {
      success = await ref.read(realtimeRidesProvider.notifier).acceptRide(ride.id);
    } else {
      success = await ref.read(ridesProvider.notifier).acceptRide(ride.id);
    }

    if (success) {
      ref.read(walletProvider.notifier).deductCredit();
      await _clusterManager.clearRoutes();

      // Start navigation to pickup
      ref.read(tripProvider.notifier).startTrip(ride);
      if (mounted) context.push('/trip');
    } else if (mounted) {
      context.showSnackBar('Failed to accept ride.', isError: true);
    }
  }

  void _rejectRide(RideEntity ride) {
    final driverOnline = ref.read(driverStatusProvider).isOnline;
    if (driverOnline) {
      ref.read(realtimeRidesProvider.notifier).rejectRide(ride.id);
    }
    _clusterManager.clearRoutes();
  }

  void _showInsufficientCreditsPopup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.warning_amber_rounded,
            color: AppColors.warning, size: 48),
        title: Text('Insufficient Credits', style: AppTextStyles.titleMedium),
        content: Text(
          'You need at least 1 credit to accept rides. '
          'Please purchase credits to continue driving.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
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

  void _showNotification(InAppNotification notification) {
    setState(() => _currentNotification = notification);
    _notificationTimer?.cancel();
    _notificationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _currentNotification = null);
    });
  }

  void _centerOnDriver() {
    final loc = ref.read(mapProvider).currentLocation;
    if (loc != null && _mapboxMap != null) {
      _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(loc.longitude, loc.latitude)),
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final driverStatus = ref.watch(driverStatusProvider);
    final ridesState = ref.watch(ridesProvider);
    final realtimeRides = ref.watch(realtimeRidesProvider);
    final walletState = ref.watch(walletProvider);

    // Listen to in-app notifications
    ref.listen(inAppNotificationStreamProvider, (_, next) {
      next.whenData((notification) => _showNotification(notification));
    });

    // Start/stop realtime listening based on online status
    ref.listen<DriverStatusState>(driverStatusProvider, (prev, next) {
      if (next.isOnline && !(prev?.isOnline ?? false)) {
        ref.read(realtimeRidesProvider.notifier).startListening();
      } else if (!next.isOnline && (prev?.isOnline ?? false)) {
        ref.read(realtimeRidesProvider.notifier).stopListening();
      }
    });

    // Combine REST and realtime ride requests
    final allPendingRides = [
      ...realtimeRides.pendingRequests,
      ...ridesState.availableRides.where(
        (r) => !realtimeRides.pendingRequests.any((p) => p.id == r.id),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // === LAYER 1: Full-screen Mapbox Map ===
          _buildMap(mapState),

          // === LAYER 2: Top header overlay ===
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DashboardHeader(
              credits: walletState.credits,
              isOnline: driverStatus.isOnline,
              onlineSince: driverStatus.onlineSince,
              onMenuTap: () => context.push('/profile'),
              onWalletTap: () => context.push('/wallet'),
              onEarningsTap: () => context.push('/earnings'),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
          ),

          // === LAYER 3: Online/Offline toggle (center) when no rides ===
          if (!driverStatus.isOnline && realtimeRides.pendingRequests.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LargeOnlineToggle(),
                  const SizedBox(height: 16),
                  Text(
                    'Go online to start receiving rides',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
            ),

          // === LAYER 4: Animated ride request cards (bottom) ===
          if (realtimeRides.pendingRequests.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RideRequestStack(
                    rides: realtimeRides.pendingRequests,
                    hasCredits: walletState.hasCredits,
                    onAccept: _acceptRide,
                    onReject: _rejectRide,
                    onTap: _onRideTapped,
                  ),
                ),
              ),
            ),

          // === LAYER 5: Browse rides carousel (when online, no pending) ===
          if (driverStatus.isOnline &&
              realtimeRides.pendingRequests.isEmpty &&
              ridesState.availableRides.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBrowseRides(ridesState, walletState.hasCredits),
            ),

          // === LAYER 6: Floating controls ===
          Positioned(
            right: 16,
            bottom: allPendingRides.isNotEmpty ? 280 : 100,
            child: Column(
              children: [
                _buildFab(
                  icon: Icons.my_location,
                  onTap: _centerOnDriver,
                ),
                const SizedBox(height: 12),
                _buildFab(
                  icon: Icons.refresh,
                  onTap: _loadNearbyRides,
                ),
              ],
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          ),

          // === LAYER 7: In-app notification banner ===
          if (_currentNotification != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: InAppNotificationBanner(
                title: _currentNotification!.title,
                body: _currentNotification!.body,
                icon: _notificationIcon(_currentNotification!.type),
                color: _notificationColor(_currentNotification!.type),
                onDismiss: () =>
                    setState(() => _currentNotification = null),
              ),
            ),

          // === LAYER 8: Loading overlay ===
          if (mapState.isLoading)
            Container(
              color: AppColors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(MapState mapState) {
    return MapWidget(
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            mapState.currentLocation?.longitude ?? 77.5946,
            mapState.currentLocation?.latitude ?? 12.9716,
          ),
        ),
        zoom: 14.0,
      ),
      styleUri: MapboxService.styleUrlDark,
      onMapCreated: _onMapCreated,
    );
  }

  Widget _buildBrowseRides(RidesState ridesState, bool hasCredits) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.darkBackground.withValues(alpha: 0.85),
            AppColors.darkBackground,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${ridesState.availableRides.length} rides nearby',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: ridesState.availableRides.length,
              itemBuilder: (context, index) {
                final ride = ridesState.availableRides[index];
                return _buildMiniRideCard(ride)
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: index * 100),
                      duration: 400.ms,
                    )
                    .slideX(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3);
  }

  Widget _buildMiniRideCard(RideEntity ride) {
    return GestureDetector(
      onTap: () => _onRideTapped(ride),
      child: Container(
        width: 260,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey700.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.trip_origin, color: AppColors.success, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ride.pickupAddress,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey300),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.error, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ride.dropAddress,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey300),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  '${ride.distanceKm.toStringAsFixed(1)} km',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(width: 8),
                Text(
                  '${ride.estimatedMinutes} min',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                ),
                const Spacer(),
                Text(
                  ride.estimatedEarnings.asCurrency,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: AppColors.darkCard,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      shadowColor: AppColors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.white),
        ),
      ),
    );
  }

  IconData _notificationIcon(InAppNotificationType type) {
    return switch (type) {
      InAppNotificationType.rideRequest => Icons.local_taxi,
      InAppNotificationType.paymentSuccess => Icons.check_circle,
      InAppNotificationType.lowCredits => Icons.warning_amber,
      InAppNotificationType.rideCancelled => Icons.cancel,
      InAppNotificationType.general => Icons.notifications,
    };
  }

  Color _notificationColor(InAppNotificationType type) {
    return switch (type) {
      InAppNotificationType.rideRequest => AppColors.primary,
      InAppNotificationType.paymentSuccess => AppColors.success,
      InAppNotificationType.lowCredits => AppColors.warning,
      InAppNotificationType.rideCancelled => AppColors.error,
      InAppNotificationType.general => AppColors.info,
    };
  }
}
