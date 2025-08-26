import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pay/smart_pay.dart';

class _DummyProvider extends PaymentProviderPlugin {
  @override
  String get id => 'dummy';

  @override
  PaymentMode get mode => PaymentMode.SDK;

  @override
  Future<PaymentResult> pay(PayRequest request) async =>
      PaymentResult.success(providerId: id, transactionId: 'tx');
}

class _FailingProvider extends PaymentProviderPlugin {
  @override
  String get id => 'failing';

  @override
  PaymentMode get mode => PaymentMode.URL;

  @override
  Future<PaymentResult> pay(PayRequest request) async =>
      PaymentResult.failure(providerId: id, message: 'Payment failed');
}

void main() {
  group('SmartPay', () {
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
      expect(result.transactionId, 'tx');
    });

    test('handles payment failure correctly', () async {
      final failing = _FailingProvider();
      SmartPay.configure(SmartPayConfig(providers: [failing]));

      final result = await SmartPay.checkout(
        const PayRequest(
            amountMinorUnits: 1000, currency: 'USD', description: 'Test'),
      );
      expect(result.success, false);
      expect(result.providerId, 'failing');
      expect(result.message, 'Payment failed');
    });

    test('supports multiple providers', () {
      final provider1 = _DummyProvider();
      final provider2 = _FailingProvider();

      SmartPay.configure(SmartPayConfig(providers: [provider1, provider2]));

      expect(SmartPay.store.providers.length, 2);
      expect(SmartPay.store.providers.map((p) => p.id).toList(),
          containsAll(['dummy', 'failing']));
    });
  });

  group('PayRequest', () {
    test('creates request with required fields', () {
      const request = PayRequest(
        amountMinorUnits: 1999,
        currency: 'USD',
      );

      expect(request.amountMinorUnits, 1999);
      expect(request.currency, 'USD');
      expect(request.flowMode, PaymentFlowMode.testing);
    });

    test('supports optional fields', () {
      const request = PayRequest(
        amountMinorUnits: 2999,
        currency: 'EUR',
        description: 'Test payment',
        flowMode: PaymentFlowMode.production,
        metadata: {'key': 'value'},
      );

      expect(request.description, 'Test payment');
      expect(request.flowMode, PaymentFlowMode.production);
      expect(request.metadata, {'key': 'value'});
    });
  });

  group('PaymentResult', () {
    test('creates success result', () {
      final result = PaymentResult.success(
        providerId: 'test',
        transactionId: 'tx123',
        message: 'Success',
        paymentUrl: 'https://example.com',
      );

      expect(result.success, true);
      expect(result.providerId, 'test');
      expect(result.transactionId, 'tx123');
      expect(result.message, 'Success');
      expect(result.paymentUrl, 'https://example.com');
    });

    test('creates failure result', () {
      final result = PaymentResult.failure(
        providerId: 'test',
        message: 'Failed',
      );

      expect(result.success, false);
      expect(result.providerId, 'test');
      expect(result.message, 'Failed');
      expect(result.transactionId, null);
      expect(result.paymentUrl, null);
    });
  });

  group('StripeURLConfig', () {
    test('creates config with defaults', () {
      const config = StripeURLConfig();

      expect(config.urlHandlingMode, UrlHandlingMode.autoRedirect);
      expect(config.allowPromotionCodes, false);
      expect(config.successUrl, null);
    });

    test('creates config with custom values', () {
      const config = StripeURLConfig(
        successUrl: 'https://success.com',
        cancelUrl: 'https://cancel.com',
        allowPromotionCodes: true,
        urlHandlingMode: UrlHandlingMode.manual,
        metadata: {'key': 'value'},
      );

      expect(config.successUrl, 'https://success.com');
      expect(config.cancelUrl, 'https://cancel.com');
      expect(config.allowPromotionCodes, true);
      expect(config.urlHandlingMode, UrlHandlingMode.manual);
      expect(config.metadata, {'key': 'value'});
    });
  });
}
