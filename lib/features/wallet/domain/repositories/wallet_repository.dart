import '../../../../core/network/api_result.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<ApiResult<WalletEntity>> getBalance();
  Future<ApiResult<List<WalletTransaction>>> getTransactions();
  Future<ApiResult<WalletEntity>> purchaseCredits(String planId);
  Future<ApiResult<WalletEntity>> deductCredit();
}
