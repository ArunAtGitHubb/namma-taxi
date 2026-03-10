import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/ride_entity.dart';

class AnimatedRideRequestCard extends StatefulWidget {
  final RideEntity ride;
  final Duration timeout;
  final bool hasCredits;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTap;

  const AnimatedRideRequestCard({
    super.key,
    required this.ride,
    this.timeout = const Duration(seconds: 15),
    required this.hasCredits,
    required this.onAccept,
    required this.onReject,
    required this.onTap,
  });

  @override
  State<AnimatedRideRequestCard> createState() =>
      _AnimatedRideRequestCardState();
}

class _AnimatedRideRequestCardState extends State<AnimatedRideRequestCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  double _dragOffset = 0;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: widget.timeout,
    )..forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isDismissed) {
        widget.onReject();
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(-120.0, 120.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset > 80) {
      HapticFeedback.heavyImpact();
      setState(() => _isDismissed = true);
      widget.onAccept();
    } else if (_dragOffset < -80) {
      HapticFeedback.lightImpact();
      setState(() => _isDismissed = true);
      widget.onReject();
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final acceptOpacity = (_dragOffset / 120).clamp(0.0, 1.0);
    final rejectOpacity = (-_dragOffset / 120).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: widget.onTap,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          // Background indicators
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _dragOffset > 0
                    ? AppColors.success.withValues(alpha: acceptOpacity * 0.3)
                    : AppColors.error.withValues(alpha: rejectOpacity * 0.3),
              ),
              child: Row(
                mainAxisAlignment: _dragOffset > 0
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Icon(
                      _dragOffset > 0 ? Icons.check_circle : Icons.close,
                      color: _dragOffset > 0 ? AppColors.success : AppColors.error,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Card content
          AnimatedContainer(
            duration: _dragOffset == 0
                ? const Duration(milliseconds: 300)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timer progress bar
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: LinearProgressIndicator(
                          value: 1 - _progressController.value,
                          backgroundColor: AppColors.grey200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _progressController.value > 0.7
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                          minHeight: 4,
                        ),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Top: Ride type + earnings
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1 + _pulseController.value * 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.local_taxi_rounded,
                                    color: AppColors.primary,
                                    size: 26,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'New Ride Request',
                                    style: AppTextStyles.titleSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      _infoChip(Icons.straighten,
                                          '${widget.ride.distanceKm.toStringAsFixed(1)} km'),
                                      const SizedBox(width: 8),
                                      _infoChip(Icons.access_time,
                                          '${widget.ride.estimatedMinutes} min'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.ride.estimatedEarnings.asCurrency,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _progressController,
                                  builder: (context, child) {
                                    final remaining = widget.timeout.inSeconds *
                                        (1 - _progressController.value);
                                    return Text(
                                      '${remaining.ceil()}s',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: _progressController.value > 0.7
                                            ? AppColors.error
                                            : AppColors.grey500,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Route
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkBackground
                                : AppColors.grey50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _routeRow(
                                icon: Icons.trip_origin,
                                color: AppColors.success,
                                text: widget.ride.pickupAddress,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Column(
                                  children: List.generate(
                                    2,
                                    (_) => Container(
                                      width: 2,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(vertical: 1),
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                ),
                              ),
                              _routeRow(
                                icon: Icons.location_on,
                                color: AppColors.error,
                                text: widget.ride.dropAddress,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Swipe hint
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chevron_left,
                                size: 16, color: AppColors.error.withValues(alpha: 0.5)),
                            Text(
                              '  Swipe to accept or reject  ',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.grey400,
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                size: 16, color: AppColors.success.withValues(alpha: 0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 1.0, end: 0.0, curve: Curves.easeOutCubic, duration: 500.ms);
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.grey600),
          const SizedBox(width: 3),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600)),
        ],
      ),
    );
  }

  Widget _routeRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Manages a stack of ride request cards with auto-expiry
class RideRequestStack extends StatefulWidget {
  final List<RideEntity> rides;
  final bool hasCredits;
  final void Function(RideEntity ride) onAccept;
  final void Function(RideEntity ride) onReject;
  final void Function(RideEntity ride) onTap;

  const RideRequestStack({
    super.key,
    required this.rides,
    required this.hasCredits,
    required this.onAccept,
    required this.onReject,
    required this.onTap,
  });

  @override
  State<RideRequestStack> createState() => _RideRequestStackState();
}

class _RideRequestStackState extends State<RideRequestStack> {
  @override
  Widget build(BuildContext context) {
    if (widget.rides.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show top card prominently
        AnimatedRideRequestCard(
          key: ValueKey(widget.rides.first.id),
          ride: widget.rides.first,
          hasCredits: widget.hasCredits,
          onAccept: () => widget.onAccept(widget.rides.first),
          onReject: () => widget.onReject(widget.rides.first),
          onTap: () => widget.onTap(widget.rides.first),
        ),

        // Stack indicator for remaining rides
        if (widget.rides.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${widget.rides.length - 1} more rides',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),
      ],
    );
  }
}
