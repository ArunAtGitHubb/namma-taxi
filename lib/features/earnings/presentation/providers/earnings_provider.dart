import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/earnings_entity.dart';

class EarningsState {
  final EarningsSummary summary;
  final bool isLoading;
  final String? error;
  final EarningsFilter filter;

  const EarningsState({
    required this.summary,
    this.isLoading = false,
    this.error,
    this.filter = EarningsFilter.weekly,
  });

  EarningsState copyWith({
    EarningsSummary? summary,
    bool? isLoading,
    String? error,
    EarningsFilter? filter,
  }) {
    return EarningsState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }
}

enum EarningsFilter { daily, weekly, monthly }

class EarningsNotifier extends StateNotifier<EarningsState> {
  final ApiClient _apiClient;

  EarningsNotifier(this._apiClient)
      : super(EarningsState(summary: EarningsSummary.empty()));

  Future<void> loadEarnings() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiClient.get(
        '/driver/earnings',
        queryParameters: {'period': state.filter.name},
      );

      final data = response.data as Map<String, dynamic>;
      final summary = EarningsSummary.fromJson(data);
      state = state.copyWith(summary: summary, isLoading: false);
    } catch (e) {
      logger.e('Failed to load earnings', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load earnings',
      );
    }
  }

  void setFilter(EarningsFilter filter) {
    state = state.copyWith(filter: filter);
    loadEarnings();
  }
}

final earningsProvider =
    StateNotifierProvider<EarningsNotifier, EarningsState>((ref) {
  return EarningsNotifier(ref.read(apiClientProvider));
});
