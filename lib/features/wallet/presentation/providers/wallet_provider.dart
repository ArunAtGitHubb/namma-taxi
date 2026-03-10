import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../services/stripe_service.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(
    WalletRemoteDataSource(ref.read(apiClientProvider)),
  );
});

class WalletState {
  final int credits;
  final bool isLoading;
  final List<WalletTransaction> transactions;
  final String? error;
  final PaymentStatus paymentStatus;

  const WalletState({
    this.credits = 0,
    this.isLoading = false,
    this.transactions = const [],
    this.error,
    this.paymentStatus = PaymentStatus.idle,
  });

  bool get hasCredits => credits > 0;
  bool get isLowCredits => credits > 0 && credits <= 5;

  WalletState copyWith({
    int? credits,
    bool? isLoading,
    List<WalletTransaction>? transactions,
    String? error,
    PaymentStatus? paymentStatus,
  }) {
    return WalletState(
      credits: credits ?? this.credits,
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      error: error,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repository;
  final StripeService _stripeService;

  WalletNotifier({
    required WalletRepository repository,
    required StripeService stripeService,
  })  : _repository = repository,
        _stripeService = stripeService,
        super(const WalletState());

  Future<void> loadBalance() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getBalance();

    switch (result) {
      case ApiSuccess<WalletEntity>():
        state = state.copyWith(
          credits: result.data.credits,
          isLoading: false,
        );
      case ApiError<WalletEntity>():
        state = state.copyWith(isLoading: false, error: result.message);
      case ApiLoading<WalletEntity>():
        break;
    }
  }

  Future<void> loadTransactions() async {
    final result = await _repository.getTransactions();

    if (result is ApiSuccess<List<WalletTransaction>>) {
      state = state.copyWith(transactions: result.data);
    }
  }

  Future<bool> purchaseCredits(CreditPlan plan) async {
    state = state.copyWith(
      isLoading: true,
      paymentStatus: PaymentStatus.idle,
    );

    final paymentResult = await _stripeService.processPayment(
      amount: plan.priceInCents,
      currency: 'usd',
      planId: plan.id,
      onStatusChange: (status) {
        state = state.copyWith(paymentStatus: status);
      },
    );

    if (!paymentResult.success) {
      state = state.copyWith(
        isLoading: false,
        error: paymentResult.errorMessage,
        paymentStatus: PaymentStatus.failed,
      );
      return false;
    }

    // Payment confirmed on backend — refresh wallet
    final result = await _repository.purchaseCredits(plan.id);

    switch (result) {
      case ApiSuccess<WalletEntity>():
        state = state.copyWith(
          credits: result.data.credits,
          isLoading: false,
          paymentStatus: PaymentStatus.success,
        );
        return true;
      case ApiError<WalletEntity>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          paymentStatus: PaymentStatus.failed,
        );
        return false;
      case ApiLoading<WalletEntity>():
        return false;
    }
  }

  void deductCredit() {
    if (state.credits > 0) {
      state = state.copyWith(credits: state.credits - 1);
    }
  }

  void clearError() {
    state = state.copyWith(error: null, paymentStatus: PaymentStatus.idle);
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(
    repository: ref.read(walletRepositoryProvider),
    stripeService: ref.read(stripeServiceProvider),
  );
});
