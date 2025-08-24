import 'package:flutter/foundation.dart';

import '../config/smart_pay_config.dart';
import '../models/pay_request.dart';
import '../models/payment_result.dart';
import '../providers/payment_provider_plugin.dart';

class SmartPayStore extends ChangeNotifier {
  SmartPayConfig? _config;
  final ValueNotifier<String?> selectedProviderId =
      ValueNotifier<String?>(null);

  Map<String, PaymentProviderPlugin> _idToProvider =
      <String, PaymentProviderPlugin>{};

  void configure(SmartPayConfig config) {
    _config = config;

    // Index providers and filter by enabled flag
    final List<PaymentProviderPlugin> enabled =
        config.providers.where((p) => p.isEnabled).toList(growable: false);
    _idToProvider = {for (final p in enabled) p.id: p};

    // Set default selection
    selectedProviderId.value = config.defaultSelectedProviderId ??
        (enabled.isNotEmpty ? enabled.first.id : null);

    notifyListeners();
  }

  List<PaymentProviderPlugin> get providers =>
      _config?.providers ?? const <PaymentProviderPlugin>[];

  List<PaymentProviderPlugin> get enabledProviders =>
      providers.where((p) => p.isEnabled).toList(growable: false);

  PaymentProviderPlugin? get selectedProvider {
    final String? id = selectedProviderId.value;
    if (id == null) return null;
    return _idToProvider[id];
  }

  void selectById(String id) {
    if (_idToProvider.containsKey(id)) {
      selectedProviderId.value = id;
      notifyListeners();
    }
  }

  Future<PaymentResult> checkout(PayRequest request) async {
    final PaymentProviderPlugin? provider = selectedProvider;
    if (provider == null) {
      return PaymentResult.failure(
        providerId: 'none',
        message: 'No payment method selected',
      );
    }

    try {
      return await provider.pay(request);
    } catch (error) {
      return PaymentResult.failure(
        providerId: provider.id,
        message: 'Payment failed: $error',
      );
    }
  }
}
