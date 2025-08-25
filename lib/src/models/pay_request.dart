import 'payment_flow_mode.dart';

class PayRequest {
  /// Amount in the smallest currency unit (e.g., cents, paise)
  final int amountMinorUnits;

  /// ISO 4217 currency code, e.g., "USD", "EUR", "INR"
  final String currency;

  /// Human-readable description shown in payment sheet or receipt
  final String? description;

  /// Optional metadata to pass through to the provider
  final Map<String, Object?>? metadata;

  /// Select how to obtain provider session (intent/order) and proceed
  final PaymentFlowMode flowMode;

  const PayRequest({
    required this.amountMinorUnits,
    required this.currency,
    this.description,
    this.metadata,
    this.flowMode = PaymentFlowMode.testing,
  });
}
