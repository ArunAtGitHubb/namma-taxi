import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/earnings_entity.dart';
import '../providers/earnings_provider.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(earningsProvider.notifier).loadEarnings());
  }

  @override
  Widget build(BuildContext context) {
    final earnings = ref.watch(earningsProvider);
    final summary = earnings.summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: [
          _buildFilterChip(earnings.filter),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(earningsProvider.notifier).loadEarnings(),
        child: earnings.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeroEarnings(summary)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.1),
                    const SizedBox(height: 20),
                    _buildStatsRow(summary)
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Weekly Earnings'),
                    const SizedBox(height: 8),
                    _buildEarningsChart(summary.weeklyBreakdown)
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Ride Activity'),
                    const SizedBox(height: 8),
                    _buildRideCountChart(summary.weeklyBreakdown)
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Recent Rides'),
                    const SizedBox(height: 8),
                    ...summary.recentRides.asMap().entries.map(
                          (entry) => _buildRideHistoryTile(entry.value)
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                    milliseconds: 500 + entry.key * 80),
                                duration: 400.ms,
                              )
                              .slideX(begin: 0.05),
                        ),
                    if (summary.recentRides.isEmpty)
                      _buildEmptyState()
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 500.ms),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFilterChip(EarningsFilter filter) {
    return PopupMenuButton<EarningsFilter>(
      onSelected: (f) => ref.read(earningsProvider.notifier).setFilter(f),
      itemBuilder: (ctx) => EarningsFilter.values
          .map((f) => PopupMenuItem(
                value: f,
                child: Row(
                  children: [
                    if (f == filter)
                      const Icon(Icons.check, size: 18, color: AppColors.primary),
                    if (f != filter) const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(f.name.capitalize),
                  ],
                ),
              ))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter.name.capitalize,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroEarnings(EarningsSummary summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Today's Earnings",
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.grey400),
          ),
          const SizedBox(height: 8),
          Text(
            summary.todayEarnings.asCurrency,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStat(
                'This Week',
                summary.weeklyEarnings.asCurrency,
                Icons.calendar_today,
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.grey700,
              ),
              _buildMiniStat(
                'This Month',
                summary.monthlyEarnings.asCurrency,
                Icons.date_range,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(EarningsSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_taxi,
              value: '${summary.todayRides}',
              label: 'Today',
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.directions_car,
              value: '${summary.totalRides}',
              label: 'Total Rides',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star,
              value: summary.averageRating > 0
                  ? summary.averageRating.toStringAsFixed(1)
                  : '—',
              label: 'Rating',
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.payments,
              value: summary.averageEarningsPerRide > 0
                  ? summary.averageEarningsPerRide.asCurrency
                  : '—',
              label: 'Per Ride',
              color: AppColors.success,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.grey500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title, style: AppTextStyles.titleMedium),
    );
  }

  Widget _buildEarningsChart(List<DailyEarning> data) {
    if (data.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No earnings data',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
          ),
        ),
      );
    }

    final maxY = data.fold<double>(0, (max, e) => e.earnings > max ? e.earnings : max);

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  data[group.x].earnings.asCurrency,
                  AppTextStyles.labelSmall.copyWith(color: AppColors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()].dayLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.grey400,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.grey200,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.earnings,
                  color: AppColors.primary,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY * 1.2,
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRideCountChart(List<DailyEarning> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.rides.toDouble());
    }).toList();

    final maxY = data.fold<double>(0, (max, e) => e.rides > max ? e.rides.toDouble() : max);

    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          maxY: maxY * 1.3,
          minY: 0,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toInt()} rides',
                    AppTextStyles.labelSmall.copyWith(color: AppColors.white),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()].dayLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.info,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.info,
                    strokeWidth: 2,
                    strokeColor: AppColors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.info.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideHistoryTile(RideHistoryItem ride) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_taxi, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.pickupAddress,
                  style: AppTextStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${ride.distanceKm.toStringAsFixed(1)} km • ${ride.completedAt.timeAgo}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ride.earnings.asCurrency,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (ride.rating != null) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text(
                      ride.rating!.toStringAsFixed(1),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.grey400),
            const SizedBox(height: 12),
            Text(
              'No rides yet',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
