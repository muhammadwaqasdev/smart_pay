import 'url_handling_mode.dart';

/// Generic URL configuration that can be used by all payment providers
class GenericURLConfig {
  /// Custom success URL to redirect to after successful payment
  final String? successUrl;

  /// Custom cancel URL to redirect to if payment is cancelled
  final String? cancelUrl;

  /// Whether to allow promotion codes (if supported by provider)
  final bool allowPromotionCodes;

  /// Metadata to attach to the payment
  final Map<String, String>? metadata;

  /// How to handle the payment URL (auto redirect or return for manual handling)
  final UrlHandlingMode urlHandlingMode;

  const GenericURLConfig({
    this.successUrl,
    this.cancelUrl,
    this.allowPromotionCodes = false,
    this.metadata,
    this.urlHandlingMode = UrlHandlingMode.autoRedirect,
  });
}
