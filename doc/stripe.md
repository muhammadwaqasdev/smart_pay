# Stripe Payment Setup

Complete guide to add Stripe payments to your Flutter app with Smart Pay.

## Overview

Stripe integration provides:
- **Credit/Debit Cards** - Visa, MasterCard, American Express, etc.
- **Digital Wallets** - Apple Pay, Google Pay (when available)
- **Local Payment Methods** - Based on your market

## Quick Setup

### 1. Get Stripe Keys

1. Create a [Stripe account](https://stripe.com)
2. Go to **Developers** → **API Keys**
3. Copy your **Publishable key** and **Secret key**

```
Publishable key: pk_test_51H... (starts with pk_)
Secret key: sk_test_51H...      (starts with sk_)
```

### 2. Add to Your App

```dart
import 'package:smart_pay/smart_pay.dart';

SmartPay.configure(SmartPayConfig(
  providers: [
    StripeProvider(
      publishableKey: 'pk_test_your_key_here',
      secretKey: 'sk_test_your_key_here',
    ),
  ],
));
```

That's it! Stripe will automatically:
- Use **in-app payments** on mobile (iOS/Android)
- Use **secure web pages** on web/desktop
- Handle all payment processing

## Customization Options

### Custom Display Name

```dart
StripeProvider(
  publishableKey: 'pk_test_...',
  secretKey: 'sk_test_...',
  displayName: 'Credit Card', // Shows as "Credit Card" in UI
)
```

### Force Payment Mode

```dart
// Force web-based payment (works on all platforms)
StripeProvider(
  publishableKey: 'pk_test_...',
  secretKey: 'sk_test_...',
  mode: PaymentMode.url, // Always uses web payment
)
```

### URL Payment Settings

```dart
StripeProvider(
  publishableKey: 'pk_test_...',
  secretKey: 'sk_test_...',
  urlConfig: StripeURLConfig(
    successUrl: 'https://yourapp.com/success',
    cancelUrl: 'https://yourapp.com/cancel',
    allowPromotionCodes: true,
    urlHandlingMode: UrlHandlingMode.manual, // or .autoRedirect
  ),
)
```

## Payment Modes

### Automatic Mode (Recommended)

```dart
StripeProvider(
  publishableKey: 'pk_test_...',
  secretKey: 'sk_test_...',
  // Automatically chooses best mode for your platform
)
```

- **Mobile**: Uses Stripe's native payment sheet
- **Web/Desktop**: Uses Stripe's hosted checkout pages

### SDK Mode (Mobile Only)

```dart
StripeProvider(
  publishableKey: 'pk_test_...',
  secretKey: 'sk_test_...',
  mode: PaymentMode.sdk, // Force in-app payment UI
)
```

✅ **Works on**: iOS, Android  
❌ **Not available on**: Web, macOS, Windows, Linux

### URL Mode (All Platforms)

```dart
StripeProvider(
  publishableKey: 'pk_test_...',
  secretKey: 'sk_test_...',
  mode: PaymentMode.url, // Force web-based payment
)
```

✅ **Works on**: All platforms

## Production Setup

### For Production Apps

```dart
StripeProvider(
  publishableKey: 'pk_live_your_live_key',
  // Don't include secretKey in production!
  createPaymentSheet: (request) async {
    // Call your backend to create payment intent
    final response = await MyAPI.createPaymentIntent(request);
    return StripePaymentSheetConfig(
      paymentIntentClientSecret: response.clientSecret,
      merchantDisplayName: 'Your Store Name',
    );
  },
)
```

### For Testing/Development

```dart
StripeProvider(
  publishableKey: 'pk_test_your_test_key',
  secretKey: 'sk_test_your_test_key', // OK for testing
)
```

## URL Handling

### Auto Redirect (Simple)

```dart
StripeURLConfig(
  urlHandlingMode: UrlHandlingMode.autoRedirect,
  successUrl: 'https://yourapp.com/success',
  cancelUrl: 'https://yourapp.com/cancel',
)
```

User is automatically redirected to their default browser.

### Manual Handling (Advanced)

```dart
StripeURLConfig(
  urlHandlingMode: UrlHandlingMode.manual,
)
```

```dart
final result = await SmartPay.checkout(paymentRequest);

if (result.paymentUrl != null) {
  // You handle the URL (WebView, custom browser, etc.)
  await launchUrl(Uri.parse(result.paymentUrl!));
}
```

## Examples

### Basic Stripe Setup

```dart
void main() {
  SmartPay.configure(SmartPayConfig(
    providers: [
      StripeProvider(
        publishableKey: 'pk_test_51H...',
        secretKey: 'sk_test_51H...',
        displayName: 'Credit Card',
      ),
    ],
  ));
  
  runApp(MyApp());
}
```

### Multiple Stripe Configurations

```dart
SmartPay.configure(SmartPayConfig(
  providers: [
    // Fast checkout (mobile SDK)
    StripeProvider(
      publishableKey: 'pk_test_...',
      secretKey: 'sk_test_...',
      displayName: 'Quick Pay',
    ),
    
    // Web checkout with promo codes
    StripeProvider(
      publishableKey: 'pk_test_...',
      secretKey: 'sk_test_...',
      displayName: 'Pay with Promo Code',
      mode: PaymentMode.url,
      urlConfig: StripeURLConfig(
        allowPromotionCodes: true,
        urlHandlingMode: UrlHandlingMode.autoRedirect,
      ),
    ),
  ],
));
```

## Troubleshooting

### Common Issues

**"Invalid API Key"**
- Check your publishable key starts with `pk_`
- Make sure you're using the right key (test vs live)

**"Payment failed"**
- Check your secret key starts with `sk_`
- Ensure you have sufficient permissions on Stripe

**"Unsupported on this platform"**
- You're trying to use SDK mode on web/desktop
- Use URL mode or automatic mode instead

### Testing

Use Stripe's test card numbers:
- **Success**: `4242424242424242`
- **Decline**: `4000000000000002`
- **Authentication**: `4000002500003155`

## Need Help?

- [Stripe Documentation](https://stripe.com/docs)
- [Smart Pay Issues](https://github.com/muhammadwaqasdev/smart_pay/issues)
- [Example App](../example/)

---

**Next Step**: Return to [main setup guide](../README.md) or check out the [example app](../example/).