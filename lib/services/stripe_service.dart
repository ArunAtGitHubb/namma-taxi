import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/utils/logger.dart';

enum PaymentStatus { idle, creatingIntent, showingSheet, confirming, success, failed }

class PaymentResult {
  final bool success;
  final PaymentStatus lastStatus;
  final String? errorMessage;
  final String? transactionId;

  const PaymentResult({
    required this.success,
    required this.lastStatus,
    this.errorMessage,
    this.transactionId,
  });
}

class StripeService {
  static const String publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';

  final ApiClient _apiClient;

  StripeService(this._apiClient);

  static Future<void> initialize() async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Full payment flow with detailed status tracking.
  /// Returns [PaymentResult] with success/failure info.
  Future<PaymentResult> processPayment({
    required int amount,
    required String currency,
    required String planId,
    void Function(PaymentStatus status)? onStatusChange,
  }) async {
    try {
      // Step 1: Create payment intent on backend
      onStatusChange?.call(PaymentStatus.creatingIntent);

      final response = await _apiClient.post(
        ApiEndpoints.createPaymentIntent,
        data: {
          'amount': amount,
          'currency': currency,
          'plan_id': planId,
        },
      );

      final clientSecret = response.data['client_secret'] as String;
      final intentId = response.data['payment_intent_id'] as String?;

      // Step 2: Initialize and present payment sheet
      onStatusChange?.call(PaymentStatus.showingSheet);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Namma Taxi',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFFFC107),
              background: Color(0xFFFFFFFF),
              componentBackground: Color(0xFFF5F5F5),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 16,
              borderWidth: 0,
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              shapes: PaymentSheetPrimaryButtonShape(),
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFFFC107),
                  text: Color(0xFF212121),
                ),
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFFFC107),
                  text: Color(0xFF212121),
                ),
              ),
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Step 3: Confirm payment on backend
      onStatusChange?.call(PaymentStatus.confirming);

      await _apiClient.post(
        ApiEndpoints.confirmPayment,
        data: {
          'plan_id': planId,
          'payment_intent_id': intentId,
        },
      );

      onStatusChange?.call(PaymentStatus.success);
      logger.i('Payment successful for plan: $planId');

      return PaymentResult(
        success: true,
        lastStatus: PaymentStatus.success,
        transactionId: intentId,
      );
    } on StripeException catch (e) {
      final message = e.error.localizedMessage ?? 'Payment cancelled';
      logger.w('Stripe error: $message');
      onStatusChange?.call(PaymentStatus.failed);

      return PaymentResult(
        success: false,
        lastStatus: PaymentStatus.failed,
        errorMessage: message,
      );
    } on DioException catch (e) {
      logger.e('API error during payment', error: e);
      onStatusChange?.call(PaymentStatus.failed);

      return PaymentResult(
        success: false,
        lastStatus: PaymentStatus.failed,
        errorMessage: 'Payment processing failed. Please try again.',
      );
    } catch (e) {
      logger.e('Unexpected payment error', error: e);
      onStatusChange?.call(PaymentStatus.failed);

      return PaymentResult(
        success: false,
        lastStatus: PaymentStatus.failed,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }
}

final stripeServiceProvider = Provider<StripeService>((ref) {
  return StripeService(ref.read(apiClientProvider));
});
