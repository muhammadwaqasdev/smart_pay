import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pay/smart_pay.dart';

void main() {
  group('Platform Detection', () {
    test('platform detector returns valid defaults', () {
      final defaults = PlatformDetector.getPlatformDefaults();

      expect(defaults['platform'], isA<String>());
      expect(defaults['defaultMode'], isA<PaymentMode>());
      expect(defaults['supportsSdk'], isA<bool>());
      expect(defaults['supportsUrl'], isA<bool>());

      // URL mode should always be supported
      expect(defaults['supportsUrl'], true);

      // Platform name should not be empty
      expect(defaults['platform'], isNotEmpty);
    });

    test('URL mode is always supported', () {
      expect(PlatformDetector.isPaymentModeSupported(PaymentMode.URL), true);
    });

    test('platform name is not empty', () {
      expect(PlatformDetector.getCurrentPlatformName(), isNotEmpty);
    });
  });

  group('StripeProvider Platform Logic', () {
    test('accepts valid platform defaults', () {
      expect(
          () => StripeProvider(
                publishableKey: 'pk_test_123',
                secretKey: 'sk_test_123',
                // Uses platform default mode
              ),
          returnsNormally);
    });

    test('accepts valid mode override', () {
      expect(
          () => StripeProvider(
                publishableKey: 'pk_test_123',
                secretKey: 'sk_test_123',
                mode: PaymentMode.URL, // URL is supported on all platforms
              ),
          returnsNormally);
    });

    test('provider has correct mode', () {
      final provider = StripeProvider(
        publishableKey: 'pk_test_123',
        secretKey: 'sk_test_123',
        mode: PaymentMode.URL,
      );

      expect(provider.mode, PaymentMode.URL);
    });

    test('custom display name override works', () {
      final provider = StripeProvider(
        publishableKey: 'pk_test_123',
        secretKey: 'sk_test_123',
        displayName: 'Custom Payment Method',
      );

      expect(provider.displayName, 'Custom Payment Method');
    });

    test('default display names based on mode', () {
      // URL mode provider
      final urlProvider = StripeProvider(
        publishableKey: 'pk_test_123',
        secretKey: 'sk_test_123',
        mode: PaymentMode.URL,
        // No custom displayName provided
      );

      expect(urlProvider.displayName, 'Stripe (Web)');
    });

    test('multiple providers with different names', () {
      final provider1 = StripeProvider(
        publishableKey: 'pk_test_123',
        secretKey: 'sk_test_123',
        displayName: 'Credit Card',
      );

      final provider2 = StripeProvider(
        publishableKey: 'pk_test_123',
        secretKey: 'sk_test_123',
        displayName: 'Pay with Browser',
      );

      expect(provider1.displayName, 'Credit Card');
      expect(provider2.displayName, 'Pay with Browser');
      expect(provider1.id, provider2.id); // Same id but different display names
    });
  });
}
