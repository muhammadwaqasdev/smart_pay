import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart' as fs;
import 'package:http/http.dart' as http;

import '../models/pay_request.dart';
import '../models/payment_flow_mode.dart';
import '../models/payment_result.dart';
import 'payment_provider_plugin.dart';

typedef CreateStripePaymentSheet = Future<StripePaymentSheetConfig> Function(
    PayRequest request);

class StripePaymentSheetConfig {
  final String paymentIntentClientSecret;
  final String merchantDisplayName;
  final String? customerId;
  final String? customerEphemeralKeySecret;
  final String? merchantCountryCode;
  final bool allowsDelayedPaymentMethods;
  final bool applePay;
  final bool googlePay;

  const StripePaymentSheetConfig({
    required this.paymentIntentClientSecret,
    this.merchantDisplayName = 'Merchant',
    this.customerId,
    this.customerEphemeralKeySecret,
    this.merchantCountryCode,
    this.allowsDelayedPaymentMethods = false,
    this.applePay = false,
    this.googlePay = false,
  });
}

class StripeProvider extends PaymentProviderPlugin {
  final String publishableKey;
  final CreateStripePaymentSheet? createPaymentSheet;
  final String? secretKey; // If provided, package will create PaymentIntent
  final Uri apiBase; // Default Stripe API base

  StripeProvider({
    required this.publishableKey,
    this.createPaymentSheet,
    this.secretKey,
    Uri? apiBase,
  }) : apiBase = apiBase ?? Uri.parse('https://api.stripe.com');

  @override
  String get id => 'stripe';

  @override
  String get displayName => 'Stripe';

  bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;
    fs.Stripe.publishableKey = publishableKey;
    _initialized = true;
  }

  @override
  Future<PaymentResult> pay(PayRequest request) async {
    try {
      _ensureInitialized();
      final cfg = await _resolveConfig(request);

      await fs.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: fs.SetupPaymentSheetParameters(
          paymentIntentClientSecret: cfg.paymentIntentClientSecret,
          merchantDisplayName: cfg.merchantDisplayName,
          customerId: cfg.customerId,
          customerEphemeralKeySecret: cfg.customerEphemeralKeySecret,
          allowsDelayedPaymentMethods: cfg.allowsDelayedPaymentMethods,
          applePay: cfg.applePay
              ? fs.PaymentSheetApplePay(
                  merchantCountryCode: cfg.merchantCountryCode ?? "US")
              : null,
          googlePay: cfg.googlePay
              ? fs.PaymentSheetGooglePay(
                  merchantCountryCode: cfg.merchantCountryCode ?? "US",
                  testEnv: true,
                )
              : null,
        ),
      );

      await fs.Stripe.instance.presentPaymentSheet();

      return PaymentResult.success(
        providerId: id,
        transactionId: 'stripe_payment_sheet',
        message: 'PaymentSheet completed',
      );
    } on fs.StripeException catch (e) {
      return PaymentResult.failure(
        providerId: id,
        message: e.error.localizedMessage ?? 'Stripe error',
      );
    } catch (e) {
      return PaymentResult.failure(
          providerId: id, message: 'Stripe failure: $e');
    }
  }

  Future<StripePaymentSheetConfig> _resolveConfig(PayRequest request) async {
    switch (request.flowMode) {
      case PaymentFlowMode.backend:
        if (createPaymentSheet == null) {
          throw StateError(
              'Stripe createPaymentSheet callback not provided for backend mode');
        }
        return createPaymentSheet!(request);
      case PaymentFlowMode.testing:
        return _createPaymentSheetViaApi(request);
      case PaymentFlowMode.auto:
        if (createPaymentSheet != null) {
          return createPaymentSheet!(request);
        }
        return _createPaymentSheetViaApi(request);
    }
  }

  Future<StripePaymentSheetConfig> _createPaymentSheetViaApi(
      PayRequest request) async {
    if (secretKey == null) {
      throw StateError(
          'Stripe secretKey is required to create PaymentIntent in-package');
    }
    final int amount = request.amountMinorUnits;
    final String currency = request.currency.toLowerCase();

    final Uri url = apiBase.replace(path: '/v1/payment_intents');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amount.toString(),
        'currency': currency,
        'automatic_payment_methods[enabled]': 'true',
        if (request.description != null) 'description': request.description!,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
          'Stripe create PaymentIntent failed: ${response.statusCode} ${response.body}');
    }
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final String clientSecret = json['client_secret'] as String;
    return StripePaymentSheetConfig(
      paymentIntentClientSecret: clientSecret,
      merchantDisplayName: 'Merchant',
      applePay: false,
      googlePay: false,
    );
  }
}
