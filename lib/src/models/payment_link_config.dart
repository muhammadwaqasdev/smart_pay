import 'url_handling_mode.dart';

class StripePaymentLinkConfig {
  /// Custom success URL to redirect to after successful payment
  final String? successUrl;

  /// Custom cancel URL to redirect to if payment is cancelled
  final String? cancelUrl;

  /// Whether to allow promotion codes
  final bool allowPromotionCodes;

  /// Collect customer information
  final PaymentLinkCustomerCollection? customerCreation;

  /// Metadata to attach to the payment
  final Map<String, String>? metadata;

  /// How to handle the payment URL (auto redirect or return for manual handling)
  final UrlHandlingMode urlHandlingMode;

  const StripePaymentLinkConfig({
    this.successUrl,
    this.cancelUrl,
    this.allowPromotionCodes = false,
    this.customerCreation,
    this.metadata,
    this.urlHandlingMode = UrlHandlingMode.autoRedirect,
  });
}

enum PaymentLinkCustomerCollection {
  /// Always collect customer information
  always,

  /// Only collect if not already provided
  ifRequired,
}

class PaymentLinkCustomField {
  final String key;
  final PaymentLinkCustomFieldType type;
  final String label;
  final bool optional;

  const PaymentLinkCustomField({
    required this.key,
    required this.type,
    required this.label,
    this.optional = false,
  });
}

enum PaymentLinkCustomFieldType {
  dropdown,
  numeric,
  text,
}
