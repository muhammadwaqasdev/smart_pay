<h1 align="center">Smart Pay</h1>

<p align="center">Unified payments for Flutter with a single API. Configure Stripe today, more gateways soon, and present a unified checkout experience.</p><br>

<p align="center">
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter"
      alt="Platform" />
  </a>
  <a href="https://pub.dartlang.org/packages/smart_pay">
    <img src="https://img.shields.io/pub/v/smart_pay.svg"
      alt="Pub Package" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/github/license/muhammadwaqasdev/smart_pay?color=red"
      alt="License: MIT" />
  </a>
  <a href="https://pub.dev/packages/smart_pay/score">
    <img src="https://img.shields.io/pub/points/smart_pay?label=Pub%20Points"
      alt="Pub Points" />
  </a>
  <a href="https://pub.dev/packages/smart_pay/score">
    <img src="https://img.shields.io/pub/popularity/smart_pay?label=Popularity"
      alt="Popularity" />
  </a>
  <a href="https://pub.dev/packages/smart_pay/score">
    <img src="https://img.shields.io/pub/likes/smart_pay?label=Pub%20Likes"
      alt="Pub Likes" />
  </a>
  <a href="https://pub.dev/packages/smart_pay">
    <img src="https://img.shields.io/badge/Dart%20SDK-%3E%3D3.8-blue?logo=dart"
      alt="Dart SDK >= 3.8" />
  </a>
</p><br>

## What is Smart Pay?

Smart Pay gives you **one simple API** to accept payments from multiple providers. Add Stripe today, PayPal tomorrow - your code stays the same.

```dart
// Same code works for Stripe, PayPal, Razorpay, etc.
final result = await SmartPay.checkout(PayRequest(
  amountMinorUnits: 1999, // $19.99
  currency: 'USD',
));
```

## Quick Start

### 1. Install

```yaml
dependencies:
  smart_pay: ^1.0.0
```

### 2. Choose Your Payment Methods

| Payment Method | Status | Documentation |
|---------------|---------|---------------|
| **Stripe** | ✅ Available | [→ Stripe Setup Guide](https://github.com/muhammadwaqasdev/smart_pay/tree/main/doc/stripe.md) |
| **PayPal** | 🔄 Coming Soon | - |
| **Razorpay** | 🔄 Coming Soon | - |
| **Apple Pay** | 🔄 Coming Soon | - |
| **Google Pay** | 🔄 Coming Soon | - |

### 3. Basic Setup

```dart
import 'package:smart_pay/smart_pay.dart';

void main() {
  // Configure your payment methods
  SmartPay.configure(SmartPayConfig(
    providers: [
      // Add your payment methods here
      // See method-specific guides above ↗️
    ],
  ));
  
  runApp(MyApp());
}
```

### 4. Show Payment Methods

```dart
// Shows available payment methods to user
SmartPayMethods(
  store: SmartPay.store,
  onMethodSelected: (method) {
    print('User selected: ${method.displayName}');
  },
)
```

### 5. Process Payment

```dart
// Process payment with selected method
final result = await SmartPay.checkout(PayRequest(
  amountMinorUnits: 1999, // $19.99
  currency: 'USD',
  description: 'Your Order #1234',
));

if (result.success) {
  print('Payment successful!');
} else {
  print('Payment failed: ${result.message}');
}
```

## How It Works

### 🎯 **Smart Platform Detection**
- **Mobile** (iOS/Android): Uses in-app payment UI when possible
- **Web/Desktop**: Uses secure payment pages
- **Override**: Force specific payment method if needed

### 🔧 **Simple Configuration**
- Add payment methods in `SmartPay.configure()`
- Each method auto-detects the best mode for your platform
- Customize names, settings per method

### 🎨 **Easy UI Integration**
- `SmartPayMethods()` - Shows payment options
- `SmartPay.checkout()` - Processes payments
- Works with your existing UI/UX

## Platform Support

| Platform | SDK Mode | URL Mode | Notes |
|----------|----------|----------|-------|
| iOS | ✅ | ✅ | SDK preferred |
| Android | ✅ | ✅ | SDK preferred |
| Web | ❌ | ✅ | URL only |
| macOS | ❌ | ✅ | URL only |
| Windows | ❌ | ✅ | URL only |
| Linux | ❌ | ✅ | URL only |

## Examples

- **[Basic Example](https://github.com/muhammadwaqasdev/smart_pay/tree/main/example)** - Simple payment setup
- **[Stripe Guide](https://github.com/muhammadwaqasdev/smart_pay/tree/main/doc/stripe.md)** - Complete Stripe integration
- **[Platform Detection](https://github.com/muhammadwaqasdev/smart_pay/tree/main/doc/platform-detection.md)** - How auto-detection works

## Need Help?

- 📖 **[Setup Guides](https://github.com/muhammadwaqasdev/smart_pay/tree/main/doc/)** - Step-by-step instructions
- ❓ **[FAQ](https://github.com/muhammadwaqasdev/smart_pay/tree/main/doc/faq.md)** - Common questions
- 🐛 **[Issues](https://github.com/muhammadwaqasdev/smart_pay/issues)** - Report bugs
- 💬 **[Discussions](https://github.com/muhammadwaqasdev/smart_pay/discussions)** - Get help

## What's Next?

1. **[Choose your payment method](https://github.com/muhammadwaqasdev/smart_pay/tree/main/doc/)** from the table above
2. **Follow the setup guide** for your chosen method
3. **Add more methods** as needed - they all work the same way!

---

<p align="center">Made with ❤️ for Flutter developers</p>