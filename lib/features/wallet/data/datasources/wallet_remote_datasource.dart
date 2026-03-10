import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/wallet_model.dart';

class WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSource(this._apiClient);

  Future<WalletModel> getBalance() async {
    final response = await _apiClient.get(ApiEndpoints.walletBalance);
    return WalletModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<WalletTransactionModel>> getTransactions() async {
    final response = await _apiClient.get(ApiEndpoints.walletTransactions);
    final list = response.data['transactions'] as List;
    return list
        .map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WalletModel> purchaseCredits(String planId) async {
    final response = await _apiClient.post(
      ApiEndpoints.purchaseCredits,
      data: {'plan_id': planId},
    );
    return WalletModel.fromJson(response.data as Map<String, dynamic>);
  }
}
