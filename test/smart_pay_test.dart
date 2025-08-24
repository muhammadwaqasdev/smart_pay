import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pay/smart_pay.dart';

class _DummyProvider extends PaymentProviderPlugin {
  @override
  String get id => 'dummy';

  @override
  Future<PaymentResult> pay(PayRequest request) async =>
      PaymentResult.success(providerId: id, transactionId: 'tx');
}

void main() {
  test('configure, select method, and checkout returns success', () async {
    // Use a dummy provider in tests to avoid platform integrations
    final dummy = _DummyProvider();
    SmartPay.configure(SmartPayConfig(providers: [dummy]));

    expect(SmartPay.store.selectedProvider?.id, 'dummy');

    final result = await SmartPay.checkout(
      const PayRequest(
          amountMinorUnits: 1000, currency: 'USD', description: 'Test'),
    );
    expect(result.success, true);
    expect(result.providerId, 'dummy');
  });
}
