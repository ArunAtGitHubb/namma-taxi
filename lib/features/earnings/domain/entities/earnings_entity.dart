import 'package:equatable/equatable.dart';

class EarningsSummary extends Equatable {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final int totalRides;
  final int todayRides;
  final int weeklyRides;
  final double averageRating;
  final double averageEarningsPerRide;
  final List<DailyEarning> weeklyBreakdown;
  final List<RideHistoryItem> recentRides;

  const EarningsSummary({
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.totalRides,
    required this.todayRides,
    required this.weeklyRides,
    required this.averageRating,
    required this.averageEarningsPerRide,
    required this.weeklyBreakdown,
    required this.recentRides,
  });

  factory EarningsSummary.empty() => const EarningsSummary(
        todayEarnings: 0,
        weeklyEarnings: 0,
        monthlyEarnings: 0,
        totalRides: 0,
        todayRides: 0,
        weeklyRides: 0,
        averageRating: 0,
        averageEarningsPerRide: 0,
        weeklyBreakdown: [],
        recentRides: [],
      );

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      todayEarnings: (json['today_earnings'] as num).toDouble(),
      weeklyEarnings: (json['weekly_earnings'] as num).toDouble(),
      monthlyEarnings: (json['monthly_earnings'] as num).toDouble(),
      totalRides: json['total_rides'] as int,
      todayRides: json['today_rides'] as int,
      weeklyRides: json['weekly_rides'] as int,
      averageRating: (json['average_rating'] as num).toDouble(),
      averageEarningsPerRide:
          (json['average_earnings_per_ride'] as num).toDouble(),
      weeklyBreakdown: (json['weekly_breakdown'] as List?)
              ?.map((e) => DailyEarning.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentRides: (json['recent_rides'] as List?)
              ?.map((e) => RideHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        todayEarnings,
        weeklyEarnings,
        totalRides,
        averageRating,
        weeklyBreakdown,
      ];
}

class DailyEarning extends Equatable {
  final String dayLabel;
  final double earnings;
  final int rides;

  const DailyEarning({
    required this.dayLabel,
    required this.earnings,
    required this.rides,
  });

  factory DailyEarning.fromJson(Map<String, dynamic> json) {
    return DailyEarning(
      dayLabel: json['day'] as String,
      earnings: (json['earnings'] as num).toDouble(),
      rides: json['rides'] as int,
    );
  }

  @override
  List<Object?> get props => [dayLabel, earnings, rides];
}

class RideHistoryItem extends Equatable {
  final String id;
  final String pickupAddress;
  final String dropAddress;
  final double earnings;
  final double distanceKm;
  final DateTime completedAt;
  final double? rating;

  const RideHistoryItem({
    required this.id,
    required this.pickupAddress,
    required this.dropAddress,
    required this.earnings,
    required this.distanceKm,
    required this.completedAt,
    this.rating,
  });

  factory RideHistoryItem.fromJson(Map<String, dynamic> json) {
    return RideHistoryItem(
      id: json['id'] as String,
      pickupAddress: json['pickup_address'] as String,
      dropAddress: json['drop_address'] as String,
      earnings: (json['earnings'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      completedAt: DateTime.parse(json['completed_at'] as String),
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, earnings, completedAt];
}
