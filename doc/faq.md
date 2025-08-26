# Frequently Asked Questions

## General Questions

### What is Smart Pay?
Smart Pay is a Flutter package that gives you one simple API to accept payments from multiple providers (Stripe, PayPal, etc.). Add one provider today, add more later - your app code stays the same.

### Which payment methods are supported?
- ✅ **Stripe** - Available now
- 🔄 **PayPal** - Coming soon
- 🔄 **Razorpay** - Coming soon  
- 🔄 **Apple Pay** - Coming soon
- 🔄 **Google Pay** - Coming soon

### How much does it cost?
Smart Pay is free and open source. You only pay the fees charged by your payment providers (Stripe, PayPal, etc.).

## Setup Questions

### Do I need a backend server?
- **For testing**: No, Smart Pay can handle everything
- **For production**: Yes, you need a backend for security

### Can I use multiple payment methods?
Yes! Add as many providers as you want:

```dart
SmartPay.configure(SmartPayConfig(
  providers: [
    StripeProvider(...),
    PayPalProvider(...),   // Coming soon
    RazorpayProvider(...), // Coming soon
  ],
));
```

### How do I handle different currencies?
Each payment supports multiple currencies:

```dart
PayRequest(
  amountMinorUnits: 1999, // $19.99 USD or €19.99 EUR
  currency: 'USD', // or 'EUR', 'GBP', etc.
)
```

## Platform Questions

### What platforms are supported?
All Flutter platforms:
- ✅ iOS - SDK and URL modes
- ✅ Android - SDK and URL modes  
- ✅ Web - URL mode only
- ✅ macOS - URL mode only
- ✅ Windows - URL mode only
- ✅ Linux - URL mode only

### What's the difference between SDK and URL modes?
- **SDK Mode**: Native payment UI inside your app (mobile only)
- **URL Mode**: Secure payment pages in browser (all platforms)

Smart Pay automatically chooses the best mode for your platform.

### Can I force a specific mode?
Yes, but be careful:

```dart
// This works on all platforms
StripeProvider(mode: PaymentMode.url)

// This only works on mobile (crashes on web/desktop)
StripeProvider(mode: PaymentMode.sdk)
```

## Stripe Questions

### Where do I get Stripe keys?
1. Create account at [stripe.com](https://stripe.com)
2. Go to **Developers** → **API Keys**
3. Copy **Publishable key** (pk_...) and **Secret key** (sk_...)

### Should I use test or live keys?
- **Development**: Use test keys (pk_test_..., sk_test_...)
- **Production**: Use live keys (pk_live_...)

### Is it safe to put secret keys in my app?
- **Testing**: Yes, test secret keys are safe
- **Production**: No! Use your backend instead

### How do I test payments?
Use Stripe's test card numbers:
- **Success**: 4242424242424242
- **Decline**: 4000000000000002
- **Authentication**: 4000002500003155

## Error Questions

### "Invalid API Key" error
- Check your key starts with `pk_` (publishable) or `sk_` (secret)
- Make sure you're using test keys during development
- Verify you copied the full key correctly

### "Unsupported on this platform" error
- You're trying to use SDK mode on web/desktop
- Use URL mode or let Smart Pay choose automatically

### "Payment failed" error
- Check your secret key is valid
- Make sure your Stripe account is active
- Try with a test card number first

### Payments work in development but not production
- You're probably using test keys in production
- Switch to live keys for production
- Set up webhook endpoints for production

## UI Questions

### How do I customize payment method names?
```dart
StripeProvider(
  displayName: 'Credit Card', // Custom name
)
```

### Can I style the payment UI?
- **SDK Mode**: Limited styling options (provider controls UI)
- **URL Mode**: No styling (provider's website)
- **Method Selection**: Full control (you build the UI)

### How do I handle payment success/failure?
```dart
final result = await SmartPay.checkout(request);

if (result.success) {
  // Payment successful
  showSuccessDialog();
} else {
  // Payment failed
  showErrorDialog(result.message);
}
```

## Advanced Questions

### Can I add my own payment provider?
Yes! Implement the `PaymentProviderPlugin` interface:

```dart
class MyProvider extends PaymentProviderPlugin {
  @override
  String get id => 'my_provider';
  
  @override
  Future<PaymentResult> pay(PayRequest request) async {
    // Your payment logic here
  }
}
```

### How do I handle webhooks?
Smart Pay doesn't handle webhooks - that's your backend's job. Set up webhook endpoints in your payment provider's dashboard.

### Can I use this with state management?
Yes! Smart Pay works with any state management solution:

```dart
// With Provider
context.read<PaymentProvider>().processPayment();

// With Bloc
BlocProvider.of<PaymentBloc>(context).add(ProcessPayment());

// With GetX
Get.find<PaymentController>().processPayment();
```

## Troubleshooting

### Payment sheet doesn't appear
- Check your platform supports SDK mode
- Verify your Stripe keys are correct
- Try URL mode instead

### Payment URL doesn't open
- Check URL handling configuration
- Verify success/cancel URLs are reachable
- Test with manual URL handling

### App crashes on startup
- Check you've called `SmartPay.configure()` before `runApp()`
- Verify all required parameters are provided
- Check platform compatibility

## Still Need Help?

- 📖 [Setup Guides](.) - Step-by-step instructions
- 💻 [Example App](../example/) - Working code samples
- 🐛 [Report Issue](https://github.com/muhammadwaqasdev/smart_pay/issues) - Found a bug?
- 💬 [Get Help](https://github.com/muhammadwaqasdev/smart_pay/discussions) - Ask questions

---

**Can't find your answer?** [Open a discussion](https://github.com/muhammadwaqasdev/smart_pay/discussions) and we'll help you out!