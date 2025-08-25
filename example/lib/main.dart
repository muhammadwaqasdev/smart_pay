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

  SmartPay.configure(
    SmartPayConfig(
      providers: [
        // Payment Sheet provider (in-app payment UI)
        StripeProvider.paymentSheet(
          publishableKey: publishableKey,
          secretKey: secretKey, // Required for testing mode
        ),

        // Payment Link provider (external redirect)
        StripeProvider.paymentLink(
          publishableKey: publishableKey,
          secretKey: secretKey, // Required for creating payment links
          paymentLinkConfig: StripePaymentLinkConfig(
            successUrl: 'https://example.com/success',
            cancelUrl: 'https://example.com/cancel',
            allowPromotionCodes: true,
            urlHandlingMode:
                UrlHandlingMode.manual, // Return URL for manual handling
            metadata: {'source': 'mobile_app'},
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
      title: 'SmartPay Example',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  String? _lastResult;

  Future<void> _pay() async {
    final result = await SmartPay.checkout(
      const PayRequest(
        amountMinorUnits: 1999,
        currency: 'USD',
        description: 'SmartPay Demo Order #1001',
        flowMode: PaymentFlowMode.testing,
      ),
    );
    log(result.toString());

    // Handle manual URL result
    if (result.success && result.paymentUrl != null) {
      _showPaymentUrlDialog(result.paymentUrl!);
    }

    setState(() => _lastResult = result.toString());
  }

  void _showPaymentUrlDialog(String paymentUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment URL Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Payment URL has been generated for manual handling:'),
            const SizedBox(height: 12),
            SelectableText(
              paymentUrl,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Here you can implement your own URL handling logic
              // For example, open in custom WebView, use custom browser, etc.
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Implement your custom URL handling here!'),
                ),
              );
            },
            child: const Text('Handle Manually'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartPay Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SmartPay Dynamic Providers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a payment method. Each provider is configured with its own mode (Payment Sheet or Payment Link).',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            SmartPayMethods(
              store: SmartPay.store,
              onMethodSelected: (provider) {
                // Get the Stripe provider and show its mode
                if (provider is StripeProvider) {
                  final mode = provider.mode == StripeMode.paymentSheet
                      ? 'Payment Sheet'
                      : 'Payment Link';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected Stripe provider in $mode mode'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                debugPrint('Selected provider: ${provider.id}');
              },
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _pay,
                child: const Text('Pay \$19.99'),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Payment Links configured with manual URL handling will return the URL for you to handle (WebView, custom browser, etc.). Auto redirect will open the default browser.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            if (_lastResult != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Last Result:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _lastResult!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
