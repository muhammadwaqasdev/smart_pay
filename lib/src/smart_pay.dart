import 'config/smart_pay_config.dart';
import 'models/pay_request.dart';
import 'models/payment_result.dart';
import 'store/smart_pay_store.dart';

export 'config/smart_pay_config.dart';
export 'models/pay_request.dart';
export 'models/payment_flow_mode.dart';
export 'models/url_config.dart';
export 'models/generic_url_config.dart';
export 'models/payment_result.dart';
export 'models/stripe_mode.dart';
export 'models/payment_mode.dart';
export 'models/url_handling_mode.dart';
export 'platform/platform_detector.dart';
export 'providers/payment_provider_plugin.dart';
export 'providers/stripe_provider.dart';
export 'widgets/smart_pay_methods.dart';

class SmartPay {
  SmartPay._();

  static final SmartPayStore _store = SmartPayStore();

  /// Access the underlying store, for advanced use-cases.
  static SmartPayStore get store => _store;

  /// Configure the library with providers and defaults.
  static void configure(SmartPayConfig config) {
    _store.configure(config);
  }

  /// Show a list of enabled methods via widget helper.
  /// Usage: SmartPayMethods(store: SmartPay.store)

  /// Execute a checkout through the currently selected provider.
  static Future<PaymentResult> checkout(PayRequest request) {
    return _store.checkout(request);
  }
}
