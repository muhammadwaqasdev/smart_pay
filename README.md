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
- Stripe PaymentSheet built-in (client-secret via backend or in-package REST)
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
Configure Stripe and present the methods widget.

```dart
import 'package:smart_pay/smart_pay.dart';

void main() {
  SmartPay.configure(
    SmartPayConfig(
      providers: [
        // Option A: In-package REST creation (dev/sandbox only)
        StripeProvider(
          publishableKey: 'pk_test_...',
          secretKey: 'sk_test_...',
        ),
        // Option B (prod): get client secret from your backend
        // StripeProvider(
        //   publishableKey: 'pk_live_...',
        //   createPaymentSheet: (req) async => StripePaymentSheetConfig(
        //     paymentIntentClientSecret: await MyApi.createIntent(req),
        //     merchantDisplayName: 'My Store',
        //   ),
        // ),
      ],
    ),
  );
}
```

Render methods and checkout:
```dart
// UI list of methods
SmartPayMethods(
store: SmartPay.store,
onMethodSelected: (provider) => print('selected: ${provider.id}'),
);

// Later: checkout with desired flow mode
final result = await SmartPay.checkout(
const PayRequest(
amountMinorUnits: 4999,
currency: 'USD',
description: 'Order #1001',
flowMode: PaymentFlowMode.auto, // backend if available, else in-package
),
);
print(result);
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
  - `PaymentResult { success, providerId, transactionId?, message?, raw? }`
  - `PaymentFlowMode { auto, backend, inPackage }`

### Stripe provider
```dart
StripeProvider(
publishableKey: 'pk_...',
// Choose one
secretKey: 'sk_test_...', // in-package REST (dev/sandbox)
// or
// createPaymentSheet: (req) async => StripePaymentSheetConfig(
//   paymentIntentClientSecret: await MyApi.createIntent(req),
//   merchantDisplayName: 'My Store',
// ),
)
```

## Examples
See `example/` for a minimal app with method selection and checkout.

## Roadmap (Coming Soon)

### Gateways
- [ ] Razorpay (Standard Checkout)
- [ ] Paystack (Standard Checkout)
- [ ] PayPal (URL + SDK flows)
- [ ] Stripe Link

### Wallets
- [ ] Apple Pay (via Stripe PaymentSheet)
- [ ] Google Pay (via Stripe PaymentSheet)

### Developer Experience
- [ ] Server helpers/snippets (Dart/Node templates)
- [ ] Advanced UI customization and theming
- [ ] More examples and cookbook

## FAQ
- Why not include secrets in production?
  - Keep server secrets on your backend; in-package REST is for local/dev only.
- Can I add my own provider?
  - Yes, implement `PaymentProviderPlugin` and register it in `SmartPay.configure`.

## Contributing
PRs and issues are welcome. See the full guidelines in [CONTRIBUTING.md](CONTRIBUTING.md).

## License
MIT - see `LICENSE`.

## Changelog
See `CHANGELOG.md` for release notes.
