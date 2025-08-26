# Setup Guide

Complete step-by-step guide to add Smart Pay to your Flutter app.

## 1. Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_pay: ^1.0.0
```

Run:
```bash
flutter pub get
```

## 2. Choose Payment Methods

Pick from available payment methods:

| Method | Status | Guide |
|--------|---------|-------|
| **Stripe** | ✅ Ready | [→ Stripe Guide](stripe.md) |
| **PayPal** | 🔄 Soon | - |
| **Razorpay** | 🔄 Soon | - |

## 3. Basic Configuration

```dart
import 'package:smart_pay/smart_pay.dart';

void main() {
  SmartPay.configure(SmartPayConfig(
    providers: [
      // Add your payment methods here
      // Follow the guides above for specific setup
    ],
  ));
  
  runApp(MyApp());
}
```

## 4. Add Payment UI

### Show Payment Methods

```dart
// Shows available payment options to user
SmartPayMethods(
  store: SmartPay.store,
  onMethodSelected: (provider) {
    print('User selected: ${provider.displayName}');
  },
)
```

### Custom Payment UI

```dart
// Or build your own UI
Widget buildPaymentMethods() {
  return ListView.builder(
    itemCount: SmartPay.store.providers.length,
    itemBuilder: (context, index) {
      final provider = SmartPay.store.providers[index];
      return ListTile(
        title: Text(provider.displayName),
        onTap: () => SmartPay.store.selectProvider(provider),
      );
    },
  );
}
```

## 5. Process Payments

```dart
Future<void> processPayment() async {
  final result = await SmartPay.checkout(PayRequest(
    amountMinorUnits: 1999, // $19.99
    currency: 'USD',
    description: 'Order #1234',
  ));

  if (result.success) {
    // Payment successful!
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Success!'),
        content: Text('Payment completed'),
      ),
    );
  } else {
    // Payment failed
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text(result.message),
      ),
    );
  }
}
```

## 6. Handle Different Scenarios

### URL-Based Payments

Some payments return a URL for manual handling:

```dart
final result = await SmartPay.checkout(request);

if (result.success && result.paymentUrl != null) {
  // Handle the payment URL yourself
  await launchUrl(Uri.parse(result.paymentUrl!));
}
```

### Testing vs Production

```dart
SmartPay.configure(SmartPayConfig(
  providers: [
    StripeProvider(
      publishableKey: kDebugMode 
        ? 'pk_test_...' // Test keys for development
        : 'pk_live_...', // Live keys for production
    ),
  ],
));
```

## 7. Error Handling

```dart
try {
  final result = await SmartPay.checkout(request);
  // Handle result
} catch (e) {
  print('Payment error: $e');
  // Show error to user
}
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:smart_pay/smart_pay.dart';

void main() {
  // Configure payment methods
  SmartPay.configure(SmartPayConfig(
    providers: [
      StripeProvider(
        publishableKey: 'pk_test_your_key_here',
        secretKey: 'sk_test_your_key_here',
        displayName: 'Credit Card',
      ),
    ],
  ));
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Column(
        children: [
          // Show payment methods
          SmartPayMethods(
            store: SmartPay.store,
            onMethodSelected: (provider) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected ${provider.displayName}')),
              );
            },
          ),
          
          // Pay button
          ElevatedButton(
            onPressed: () => _processPayment(context),
            child: Text('Pay \$19.99'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    final result = await SmartPay.checkout(PayRequest(
      amountMinorUnits: 1999,
      currency: 'USD',
      description: 'Test Order',
    ));

    final message = result.success ? 'Payment Success!' : result.message;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

## What's Next?

1. **Choose a payment method** from the table above
2. **Follow the specific setup guide** for your chosen method
3. **Test with test credentials** before going live
4. **Add more payment methods** as needed

---

**Need help?** Check the [FAQ](faq.md) or [report an issue](https://github.com/muhammadwaqasdev/smart_pay/issues).