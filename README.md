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

<!-- coming soon: Razorpay • Paystack • PayPal • Apple Pay • Google Pay • Stripe Link -->

## Contents
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Platform setup](#platform-setup)
- [Quick start](#quick-start)
- [API](#api)
- [Examples](#examples)
- [Roadmap (Coming Soon)](#roadmap-coming-soon)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)
- [Changelog](#changelog)

## Overview
smart_pay lets you register multiple payment providers (starting with Stripe) and drive them with one consistent API. Render a single widget to pick a method and call one function to checkout.

## Features
- Configure providers via `SmartPay.configure`
- Show enabled methods with `SmartPayMethods`
- Checkout using the selected method with `SmartPay.checkout`
- Simple provider contract `PaymentProviderPlugin` to add gateways
- **Stripe PaymentSheet** built-in (in-app payment UI)
- **Stripe Payment Links** built-in (redirect to external Stripe-hosted pages)
- Provider-driven mode selection (Payment Sheet vs Payment Link)
- Store holds config and current selection

## Installation
Add the package to your pubspec:
```yaml
dependencies:
  smart_pay: any
```

## Platform setup
Stripe requires minimal platform configuration.

### iOS
- In `ios/Runner/Info.plist`, add URL scheme for Stripe:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
<string>stripe</string>
</array>
```
- Minimum iOS 12+ recommended.

### Android
- Ensure Android Gradle plugin and Kotlin versions meet Stripe requirements (AGP 8+, Kotlin 1.8+ recommended).
- Target Android 21+.

Refer to Stripe plugin docs if you encounter platform issues.

## Quick start
Configure Stripe providers with different modes. The package automatically generates payment links and intents for you!

```dart
import 'package:smart_pay/smart_pay.dart';

void main() {
  SmartPay.configure(
    SmartPayConfig(
      providers: [
        // Payment Sheet provider (in-app payment UI)
        StripeProvider.paymentSheet(
          publishableKey: 'pk_test_...',
          secretKey: 'sk_test_...',  // Required for testing mode
        ),
        
        // Payment Link provider (automatically generates links)
        StripeProvider.paymentLink(
          publishableKey: 'pk_test_...',
          secretKey: 'sk_test_...',  // Required for creating payment links
          paymentLinkConfig: StripePaymentLinkConfig(
            successUrl: 'https://yourapp.com/success',
            cancelUrl: 'https://yourapp.com/cancel',
            allowPromotionCodes: true,
          ),
        ),
      ],
    ),
  );
}
```

Render methods and checkout:
```dart
// UI list of methods (each provider determines its own behavior)
SmartPayMethods(
  store: SmartPay.store,
  onMethodSelected: (provider) {
    // Each provider can be Payment Sheet or Payment Link
    if (provider is StripeProvider) {
      print('Selected ${provider.mode == StripeMode.paymentSheet ? "Payment Sheet" : "Payment Link"}');
    }
  },
);

// Single checkout method works with all provider modes
final result = await SmartPay.checkout(
  const PayRequest(
    amountMinorUnits: 4999,
    currency: 'USD',
    description: 'Order #1001',
    flowMode: PaymentFlowMode.testing, // or PaymentFlowMode.production
  ),
);

// Handle the result
if (result.success) {
  if (result.paymentUrl != null) {
    // Manual URL handling - you get the URL to handle yourself
    print('Payment URL: ${result.paymentUrl}');
    // Open in custom WebView, custom browser, etc.
  } else {
    // Auto redirect completed or Payment Sheet finished
    print('Payment completed: ${result.message}');
  }
} else {
  print('Payment failed: ${result.message}');
}
```

## API
- `SmartPay.configure(SmartPayConfig)`
  - Registers providers and optional default selection
- `SmartPayMethods({ store, onMethodSelected })`
  - Stateless widget showing enabled providers as selectable chips
- `SmartPay.checkout(PayRequest)`
  - Uses selected provider to complete payment and returns `PaymentResult`
- `PaymentProviderPlugin`
  - Implement `id`, `pay()` to add a gateway
- Models
  - `PayRequest { amountMinorUnits, currency, description?, metadata?, flowMode }`
  - `PaymentResult { success, providerId, transactionId?, message?, raw?, paymentUrl? }`
  - `PaymentFlowMode { testing, production }`
  - `UrlHandlingMode { autoRedirect, manual }`

### Stripe providers

#### Payment Sheet (In-app UI)
```dart
// Testing mode - package creates payment intents automatically
StripeProvider.paymentSheet(
  publishableKey: 'pk_test_...',
  secretKey: 'sk_test_...',  // Required for testing mode
)

// Production mode - use your backend callback
StripeProvider.paymentSheet(
  publishableKey: 'pk_live_...',
  createPaymentSheet: (req) async => StripePaymentSheetConfig(
    paymentIntentClientSecret: await MyApi.createIntent(req),
    merchantDisplayName: 'My Store',
  ),
)
```

#### Payment Link (External redirect)
```dart
StripeProvider.paymentLink(
  publishableKey: 'pk_test_...',
  secretKey: 'sk_test_...', // Required for creating payment links
  paymentLinkConfig: StripePaymentLinkConfig(
    successUrl: 'myapp://payment/success',
    cancelUrl: 'myapp://payment/cancel',
    allowPromotionCodes: true,
    urlHandlingMode: UrlHandlingMode.autoRedirect, // autoRedirect: Auto open in browser / manual: Return URL for manual handling
    customerCreation: PaymentLinkCustomerCollection.always,
    metadata: {'source': 'mobile_app'},
  ),
)
```

## Examples
See `example/` for a minimal app with method selection and checkout.

### Running the Example
1. Copy the environment template: `cp example/.env.example example/.env`
2. Add your Stripe test keys to `example/.env`
3. Run: `cd example && flutter run`

See `example/README.md` for detailed setup instructions.

## Roadmap (Coming Soon)

### Gateways
- [x] Stripe PaymentSheet
- [x] Stripe Payment Links
- [ ] Razorpay (Standard Checkout)
- [ ] Paystack (Standard Checkout)  
- [ ] PayPal (URL + SDK flows)

### Wallets
- [ ] Apple Pay (via Stripe PaymentSheet)
- [ ] Google Pay (via Stripe PaymentSheet)

### Developer Experience
- [ ] Server helpers/snippets (Dart/Node templates)
- [ ] Advanced UI customization and theming
- [ ] More examples and cookbook

## FAQ

### General
- **Why not include secrets in production?**
  - Keep server secrets on your backend; in-package REST is for local/dev only.
- **Can I add my own provider?**
  - Yes, implement `PaymentProviderPlugin` and register it in `SmartPay.configure`.

### Payment Links
- **When should I use Payment Links vs Payment Sheet?**
  - Use Payment Sheet for seamless in-app payments. Use Payment Links when you need Stripe's hosted checkout experience or want to minimize integration complexity.
- **Do I need to create Payment Links manually in Stripe?**
  - No! The package automatically generates payment links based on your PayRequest. Just provide your secret key and the package handles the rest.
- **How do I handle payment completion with Payment Links?**
  - Set up success/cancel URLs and use webhooks for reliable payment confirmation. Payment Links redirect externally, so the `PaymentResult` only indicates if the link was opened successfully.
- **Can I have both Payment Sheet and Payment Link providers?**
  - Yes! Configure multiple providers and let users choose their preferred payment method.

### Configuration
- **How does the provider mode selection work?**
  - Each provider is configured with a specific mode (Payment Sheet or Payment Link) during setup. The checkout method automatically uses the appropriate flow based on the selected provider.

### URL Handling
- **What's the difference between auto redirect and manual URL handling?**
  - Auto redirect (`UrlHandlingMode.autoRedirect`) automatically opens the payment URL in the external browser. Manual (`UrlHandlingMode.manual`) returns the URL in `PaymentResult.paymentUrl` for you to handle (custom WebView, in-app browser, etc.).
- **When should I use manual URL handling?**
  - Use manual when you want to control the user experience (custom WebView, specific browser, custom UI, etc.). Use auto redirect for the simplest integration.
- **Does this apply to other payment systems?**
  - Yes! This URL handling pattern will be used for all future URL-based payment systems (PayPal, etc.).

## Contributing
PRs and issues are welcome. See the full guidelines in [CONTRIBUTING.md](CONTRIBUTING.md).

## License
MIT - see `LICENSE`.

## Changelog
See `CHANGELOG.md` for release notes.
