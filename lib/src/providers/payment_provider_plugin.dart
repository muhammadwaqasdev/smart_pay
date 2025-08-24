import '../models/pay_request.dart';
import '../models/payment_result.dart';

/// Contract for payment provider plugins (Stripe, PayPal, Razorpay, etc.)
abstract class PaymentProviderPlugin {
  /// Unique identifier for the provider. Example: 'stripe', 'paypal'.
  String get id;

  /// Display name for UI purposes. Defaults to [id] when not overridden.
  String get displayName => id;

  /// Whether this provider is enabled. Widgets will only show enabled providers.
  bool get isEnabled => true;

  /// Execute a payment using the given [request].
  Future<PaymentResult> pay(PayRequest request);
}
