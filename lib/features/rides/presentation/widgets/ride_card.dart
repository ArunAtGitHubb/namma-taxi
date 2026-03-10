import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/ride_entity.dart';

class RideCard extends StatelessWidget {
  final RideEntity ride;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final bool hasCredits;

  const RideCard({
    super.key,
    required this.ride,
    this.onTap,
    this.onAccept,
    this.hasCredits = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildLocationDots(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _buildAddressRow(ride.pickupAddress, 'Pickup'),
                      const Divider(height: 16),
                      _buildAddressRow(ride.dropAddress, 'Drop off'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  Icons.straighten,
                  '${ride.distanceKm.toStringAsFixed(1)} km',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.access_time,
                  '${ride.estimatedMinutes} min',
                ),
                const Spacer(),
                Text(
                  ride.estimatedEarnings.asCurrency,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (onAccept != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasCredits ? AppColors.primary : AppColors.grey400,
                    foregroundColor: AppColors.grey900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    hasCredits ? 'Accept Ride' : 'No Credits',
                    style: AppTextStyles.labelLarge,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDots() {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        ...List.generate(
          3,
          (_) => Container(
            width: 2,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 1),
            color: AppColors.grey400,
          ),
        ),
        const Icon(Icons.location_on, color: AppColors.error, size: 16),
      ],
    );
  }

  Widget _buildAddressRow(String address, String label) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.grey500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grey600),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}
