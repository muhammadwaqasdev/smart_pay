import 'package:flutter/material.dart';
import 'package:smart_pay/smart_pay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SmartPay.configure(
    SmartPayConfig(
      providers: [
        StripeProvider(publishableKey: 'pk_test_123', secretKey: 'sk_test_123'),
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
        flowMode: PaymentFlowMode.inPackage,
      ),
    );
    setState(() => _lastResult = result.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartPay Example')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmartPayMethods(
            store: SmartPay.store,
            onMethodSelected: (provider) {
              debugPrint('Selected provider: ${provider.id}');
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: _pay,
              child: const Text('Pay \$19.99'),
            ),
          ),
          if (_lastResult != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Last result: $_lastResult'),
            ),
        ],
      ),
    );
  }
}
