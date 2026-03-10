import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String id;
  final int credits;
  final DateTime updatedAt;

  const WalletEntity({
    required this.id,
    required this.credits,
    required this.updatedAt,
  });

  bool get hasCredits => credits > 0;
  bool get isLow => credits > 0 && credits <= 5;

  @override
  List<Object?> get props => [id, credits, updatedAt];
}

class CreditPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final int credits;
  final int priceInCents;
  final bool isPopular;

  const CreditPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    required this.priceInCents,
    this.isPopular = false,
  });

  double get priceInDollars => priceInCents / 100;
  double get pricePerCredit => priceInDollars / credits;

  @override
  List<Object?> get props => [id, name, credits, priceInCents];

  static const List<CreditPlan> defaultPlans = [
    CreditPlan(
      id: 'starter',
      name: 'Starter Plan',
      description: 'Perfect for getting started',
      credits: 10,
      priceInCents: 999,
    ),
    CreditPlan(
      id: 'pro',
      name: 'Pro Plan',
      description: 'Best value for regular drivers',
      credits: 50,
      priceInCents: 3999,
      isPopular: true,
    ),
    CreditPlan(
      id: 'elite',
      name: 'Elite Plan',
      description: 'Maximum savings for power drivers',
      credits: 100,
      priceInCents: 6999,
    ),
  ];
}

class WalletTransaction extends Equatable {
  final String id;
  final TransactionType type;
  final int credits;
  final String description;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.credits,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, credits, description, createdAt];
}

enum TransactionType { purchase, rideAccepted, refund, bonus }
