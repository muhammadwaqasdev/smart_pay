import 'url_handling_mode.dart';

class StripeURLConfig {
  /// Custom success URL to redirect to after successful payment
  final String? successUrl;

  /// Custom cancel URL to redirect to if payment is cancelled
  final String? cancelUrl;

  /// Whether to allow promotion codes
  final bool allowPromotionCodes;

  /// Collect customer information
  final URLCustomerCollection? customerCreation;

  /// Metadata to attach to the payment
  final Map<String, String>? metadata;

  /// How to handle the payment URL (auto redirect or return for manual handling)
  final UrlHandlingMode urlHandlingMode;

  const StripeURLConfig({
    this.successUrl,
    this.cancelUrl,
    this.allowPromotionCodes = false,
    this.customerCreation,
    this.metadata,
    this.urlHandlingMode = UrlHandlingMode.autoRedirect,
  });
}

enum URLCustomerCollection {
  /// Always collect customer information
  always,

  /// Only collect if not already provided
  ifRequired,
}

class URLCustomField {
  final String key;
  final URLCustomFieldType type;
  final String label;
  final bool optional;

  const URLCustomField({
    required this.key,
    required this.type,
    required this.label,
    this.optional = false,
  });
}

enum URLCustomFieldType {
  dropdown,
  numeric,
  text,
}
