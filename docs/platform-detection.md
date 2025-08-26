# Platform Detection Guide

How Smart Pay automatically chooses the best payment method for your platform.

## How It Works

Smart Pay automatically detects your platform and chooses the best payment experience:

```dart
// This code works everywhere, but behaves differently per platform
StripeProvider(
  publishableKey: 'pk_test_...',
  secretKey: 'sk_test_...',
)
```

## Platform Behavior

| Platform | Default Mode | Payment Experience |
|----------|-------------|-------------------|
| **iOS** | SDK | Native payment sheet with Apple Pay |
| **Android** | SDK | Native payment sheet with Google Pay |
| **Web** | URL | Secure payment page in browser |
| **macOS** | URL | Secure payment page in browser |
| **Windows** | URL | Secure payment page in browser |
| **Linux** | URL | Secure payment page in browser |

## SDK Mode (Mobile Only)

**What it is**: Native payment UI built into your app

**Benefits**:
- Seamless user experience
- No leaving your app
- Supports Apple Pay / Google Pay
- Better conversion rates

**Available on**: iOS, Android only

```dart
StripeProvider(
  mode: PaymentMode.SDK, // Force SDK mode
)
```

## URL Mode (All Platforms)

**What it is**: Secure payment pages hosted by the payment provider

**Benefits**:
- Works on all platforms
- Always up-to-date security
- Provider handles UI/UX
- Less integration complexity

**Available on**: All platforms

```dart
StripeProvider(
  mode: PaymentMode.URL, // Force URL mode
)
```

## Check Platform Capabilities

```dart
import 'package:smart_pay/smart_pay.dart';

void checkPlatform() {
  final info = PlatformDetector.getPlatformDefaults();
  
  print('Platform: ${info['platform']}');        // "iOS", "Web", etc.
  print('Default mode: ${info['defaultMode']}'); // PaymentMode.SDK or PaymentMode.URL
  print('Supports SDK: ${info['supportsSdk']}'); // true/false
  print('Supports URL: ${info['supportsUrl']}'); // always true
}
```

## Override Platform Detection

### Force Specific Mode

```dart
// Force URL mode on all platforms (including mobile)
StripeProvider(
  publishableKey: 'pk_test_...',
  mode: PaymentMode.URL,
)

// Force SDK mode (will error on web/desktop)
StripeProvider(
  publishableKey: 'pk_test_...',
  mode: PaymentMode.SDK, // Only works on mobile
)
```

### Error Handling

```dart
try {
  final provider = StripeProvider(
    publishableKey: 'pk_test_...',
    mode: PaymentMode.SDK, // Might not be supported
  );
} catch (e) {
  print('Error: $e');
  // UnsupportedError: Payment mode PaymentMode.SDK is not supported on Web.
}
```

## Best Practices

### ✅ Recommended (Automatic)

```dart
// Let Smart Pay choose the best mode for each platform
StripeProvider(
  publishableKey: 'pk_test_...',
  secretKey: 'sk_test_...',
)
```

### ✅ Good (URL Everywhere)

```dart
// Consistent experience across all platforms
StripeProvider(
  publishableKey: 'pk_test_...',
  mode: PaymentMode.URL,
)
```

### ❌ Not Recommended

```dart
// Will crash on web/desktop platforms
StripeProvider(
  publishableKey: 'pk_test_...',
  mode: PaymentMode.SDK, // Don't force SDK
)
```

## Examples

### Debug Platform Info

```dart
void main() {
  // Check what platform you're on
  final platform = PlatformDetector.getPlatformDefaults();
  print('Running on: ${platform['platform']}');
  print('Will use: ${platform['defaultMode']} mode');
  
  SmartPay.configure(SmartPayConfig(
    providers: [
      StripeProvider(
        publishableKey: 'pk_test_...',
        secretKey: 'sk_test_...',
      ),
    ],
  ));
}
```

### Platform-Specific Names

```dart
SmartPay.configure(SmartPayConfig(
  providers: [
    // Automatic mode with smart naming
    StripeProvider(
      publishableKey: 'pk_test_...',
      secretKey: 'sk_test_...',
      displayName: PlatformDetector.getCurrentPlatformName() == 'Web' 
        ? 'Pay Online' 
        : 'Pay with Card',
    ),
  ],
));
```

---

**Next**: [Return to main guide](../README.md) or check [Stripe setup](stripe.md)