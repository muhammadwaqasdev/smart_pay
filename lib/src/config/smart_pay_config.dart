import '../providers/payment_provider_plugin.dart';

class SmartPayConfig {
  /// List of provider plugins to register. Instantiate with credentials if needed.
  final List<PaymentProviderPlugin> providers;

  /// Optional default selected provider id. If null, first enabled provider is used.
  final String? defaultSelectedProviderId;

  const SmartPayConfig({
    required this.providers,
    this.defaultSelectedProviderId,
  });
}
