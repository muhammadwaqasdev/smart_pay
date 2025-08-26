import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart' as fs;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../models/pay_request.dart';
import '../models/payment_flow_mode.dart';
import '../models/url_config.dart';
import '../models/payment_result.dart';
import '../models/stripe_mode.dart';
import '../models/payment_mode.dart';
import '../models/url_handling_mode.dart';
import '../platform/platform_detector.dart';
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
  final String? secretKey; // Required for testing mode and payment links
  final Uri apiBase; // Default Stripe API base
  final PaymentMode _selectedMode; // The actual payment mode to use
  final String? _customDisplayName; // Custom display name override
  final StripeURLConfig? urlConfig; // Optional config for URL-based payments

  StripeProvider({
    required this.publishableKey,
    this.createPaymentSheet,
    this.secretKey,
    PaymentMode? mode, // Optional override for platform default
    String? displayName, // Optional override for method display name
    this.urlConfig,
    Uri? apiBase,
  })  : _selectedMode = _determinePaymentMode(mode),
        _customDisplayName = displayName,
        apiBase = apiBase ?? Uri.parse('https://api.stripe.com');

  /// Determine the payment mode to use based on platform and user override
  static PaymentMode _determinePaymentMode(PaymentMode? override) {
    // If user provides an override, validate it and use it
    if (override != null) {
      if (!PlatformDetector.isPaymentModeSupported(override)) {
        throw UnsupportedError(
            'Payment mode $override is not supported on ${PlatformDetector.getCurrentPlatformName()}. '
            'Supported modes: ${PlatformDetector.isPaymentModeSupported(PaymentMode.SDK) ? "SDK, " : ""}URL');
      }
      return override;
    }

    // Use platform default
    return PlatformDetector.getDefaultPaymentMode();
  }

  @override
  String get id => 'stripe';

  @override
  String get displayName => _customDisplayName ?? _getDefaultDisplayName();

  /// Get default display name based on mode
  String _getDefaultDisplayName() {
    switch (_selectedMode) {
      case PaymentMode.SDK:
        return 'Stripe (In-App)';
      case PaymentMode.URL:
        return 'Stripe (Web)';
    }
  }

  @override
  PaymentMode get mode => _selectedMode;

  /// Internal Stripe-specific mode for routing
  StripeMode get stripeMode {
    switch (_selectedMode) {
      case PaymentMode.SDK:
        return StripeMode.SDK;
      case PaymentMode.URL:
        return StripeMode.URL;
    }
  }

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

      // Route to appropriate handler based on provider mode
      switch (_selectedMode) {
        case PaymentMode.SDK:
          return await _handlePaymentSheet(request);
        case PaymentMode.URL:
          return await _handleURL(request);
      }
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

  /// Handle Payment Sheet flow
  Future<PaymentResult> _handlePaymentSheet(PayRequest request) async {
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
  }

  /// Handle URL flow
  Future<PaymentResult> _handleURL(PayRequest request) async {
    try {
      // Create payment link dynamically based on the request
      final String paymentUrl = await _createPaymentLink(request);
      final config = urlConfig ?? const StripeURLConfig();

      // Handle URL based on configuration
      switch (config.urlHandlingMode) {
        case UrlHandlingMode.autoRedirect:
          // Auto redirect to external browser
          final Uri uri = Uri.parse(paymentUrl);
          final bool launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          if (!launched) {
            return PaymentResult.failure(
              providerId: id,
              message: 'Could not launch Payment Link URL',
              paymentUrl: paymentUrl,
            );
          }

          return PaymentResult.success(
            providerId: id,
            transactionId: 'stripe_payment_link_opened',
            message: 'Payment URL opened successfully',
          );

        case UrlHandlingMode.manual:
          // Return URL for manual handling by developer
          return PaymentResult.success(
            providerId: id,
            transactionId: 'stripe_payment_link_created',
            message: 'Payment URL created successfully',
            paymentUrl: paymentUrl,
          );
      }
    } catch (e) {
      return PaymentResult.failure(
        providerId: id,
        message: 'Failed to create Payment URL: $e',
      );
    }
  }

  /// Create a Payment Link dynamically based on the PayRequest
  Future<String> _createPaymentLink(PayRequest request) async {
    if (secretKey == null) {
      throw StateError(
          'Stripe secretKey is required to create Payment URLs in testing mode');
    }

    // Create a price/product dynamically
    final int amount = request.amountMinorUnits;
    final String currency = request.currency.toLowerCase();
    final String description = request.description ?? 'Payment';

    // Step 1: Create a Price
    final Uri priceUrl = apiBase.replace(path: '/v1/prices');
    final priceResponse = await http.post(
      priceUrl,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'unit_amount': amount.toString(),
        'currency': currency,
        'product_data[name]': description,
      },
    );

    if (priceResponse.statusCode < 200 || priceResponse.statusCode >= 300) {
      throw StateError(
          'Failed to create Stripe Price: ${priceResponse.statusCode} ${priceResponse.body}');
    }

    final Map<String, dynamic> priceJson =
        jsonDecode(priceResponse.body) as Map<String, dynamic>;
    final String priceId = priceJson['id'] as String;

    // Step 2: Create Payment Link
    final Uri paymentLinkUrl = apiBase.replace(path: '/v1/payment_links');
    final Map<String, String> paymentLinkData = {
      'line_items[0][price]': priceId,
      'line_items[0][quantity]': '1',
    };

    final config = urlConfig ?? const StripeURLConfig();

    // Add optional configuration
    if (config.successUrl != null) {
      paymentLinkData['after_completion[type]'] = 'redirect';
      paymentLinkData['after_completion[redirect][url]'] = config.successUrl!;
    }

    if (config.allowPromotionCodes) {
      paymentLinkData['allow_promotion_codes'] = 'true';
    }

    if (config.customerCreation != null) {
      paymentLinkData['customer_creation'] =
          config.customerCreation == URLCustomerCollection.always
              ? 'always'
              : 'if_required';
    }

    // Add metadata
    if (config.metadata != null) {
      for (final entry in config.metadata!.entries) {
        paymentLinkData['metadata[${entry.key}]'] = entry.value;
      }
    }

    // Add request metadata
    if (request.metadata != null) {
      for (final entry in request.metadata!.entries) {
        paymentLinkData['metadata[${entry.key}]'] = entry.value.toString();
      }
    }

    final paymentLinkResponse = await http.post(
      paymentLinkUrl,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: paymentLinkData,
    );

    if (paymentLinkResponse.statusCode < 200 ||
        paymentLinkResponse.statusCode >= 300) {
      throw StateError(
          'Failed to create Payment URL: ${paymentLinkResponse.statusCode} ${paymentLinkResponse.body}');
    }

    final Map<String, dynamic> paymentLinkJson =
        jsonDecode(paymentLinkResponse.body) as Map<String, dynamic>;
    final String paymentUrlResult = paymentLinkJson['url'] as String;

    return paymentUrlResult;
  }

  Future<StripePaymentSheetConfig> _resolveConfig(PayRequest request) async {
    switch (request.flowMode) {
      case PaymentFlowMode.production:
        if (createPaymentSheet == null) {
          throw StateError(
              'Stripe createPaymentSheet callback is required for production mode');
        }
        return createPaymentSheet!(request);
      case PaymentFlowMode.testing:
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
