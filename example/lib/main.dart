import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_pay/smart_pay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Get API keys from environment
  final String publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  final String secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  if (publishableKey.isEmpty || secretKey.isEmpty) {
    throw Exception(
      'Please set STRIPE_PUBLISHABLE_KEY and STRIPE_SECRET_KEY in your .env file',
    );
  }

  // Configure Smart Pay with payment methods
  SmartPay.configure(
    SmartPayConfig(
      providers: [
        // Stripe provider with custom name
        StripeProvider(
          publishableKey: publishableKey,
          secretKey: secretKey,
          displayName: 'Credit Card',
        ),

        // Another Stripe provider for web payments
        StripeProvider(
          publishableKey: publishableKey,
          secretKey: secretKey,
          displayName: 'Pay Online',
          mode: PaymentMode.url, // Force web payment
          urlConfig: StripeURLConfig(
            successUrl: 'https://example.com/success',
            cancelUrl: 'https://example.com/cancel',
            allowPromotionCodes: true,
            urlHandlingMode: UrlHandlingMode.manual,
          ),
        ),
      ],
    ),
  );

  runApp(const SmartPayExampleApp());
}

class SmartPayExampleApp extends StatelessWidget {
  const SmartPayExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pay Example',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const CheckoutScreen(),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Get platform info for display
    final platformInfo = PlatformDetector.getPlatformDefaults();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Pay Checkout'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Platform info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform: ${platformInfo['platform']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Default Mode: ${platformInfo['defaultMode']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'SDK Support: ${platformInfo['supportsSdk'] ? 'Yes' : 'No'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Payment methods section
            Text(
              'Choose Payment Method',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Smart Pay Methods widget
            SmartPayMethods(
              store: SmartPay.store,
              onMethodSelected: (provider) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected: ${provider.displayName}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Order summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Smart Pay Demo Item'), Text('\$19.99')],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '\$19.99',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pay button
            FilledButton(
              onPressed: _isLoading ? null : _processPayment,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Pay \$19.99', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 16),

            // Help text
            Text(
              'This is a demo app. No real charges will be made.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SmartPay.checkout(
        const PayRequest(
          amountMinorUnits: 1999, // $19.99
          currency: 'USD',
          description: 'Smart Pay Demo Purchase',
          flowMode: PaymentFlowMode.testing,
        ),
      );

      // Log the result for debugging
      log('Payment result: ${result.toString()}');

      // Handle payment URL if present (for URL-based payments)
      if (result.success && result.paymentUrl != null) {
        _showPaymentUrlDialog(result.paymentUrl!);
      } else {
        // Show result dialog
        _showResultDialog(result);
      }
    } catch (e) {
      log('Payment error: $e');
      _showResultDialog(
        PaymentResult.failure(
          providerId: 'unknown',
          message: 'Payment failed: $e',
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResultDialog(PaymentResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(
          result.success ? Icons.check_circle : Icons.error,
          color: result.success ? Colors.green : Colors.red,
          size: 48,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              result.success ? 'Payment Successful!' : 'Payment Failed',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              result.message ?? 'No additional information',
              textAlign: TextAlign.center,
            ),
            if (result.transactionId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Transaction ID: ${result.transactionId}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentUrlDialog(String paymentUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment URL Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A payment URL was generated for manual handling:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                paymentUrl,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Here you would implement your URL handling logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Implement custom URL handling here!'),
                ),
              );
            },
            child: const Text('Handle URL'),
          ),
        ],
      ),
    );
  }
}
