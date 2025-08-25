# SmartPay Example App

This example app demonstrates how to use the SmartPay package with Stripe Payment Sheets and Payment Links.

## Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Environment Variables
1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Get your Stripe API keys:
   - Go to [Stripe Dashboard](https://dashboard.stripe.com)
   - Create an account or log in
   - Make sure you're in **Test mode** (toggle in the left sidebar)
   - Go to **Developers** → **API keys**
   - Copy your **Publishable key** (starts with `pk_test_`)
   - Copy your **Secret key** (starts with `sk_test_`)

3. Update your `.env` file:
   ```env
   STRIPE_PUBLISHABLE_KEY=pk_test_your_actual_publishable_key_here
   STRIPE_SECRET_KEY=sk_test_your_actual_secret_key_here
   ```

⚠️ **Important**: Never commit your `.env` file to version control. The `.env` file is already in `.gitignore`.

### 3. Run the App
```bash
flutter run
```

## Features Demonstrated

### Payment Sheet Provider
- In-app payment UI using Stripe's native payment sheet
- Handles card payments, Apple Pay, Google Pay (when configured)

### Payment Link Provider  
- External redirect to Stripe-hosted payment pages
- Manual URL handling - returns the payment URL for custom handling
- Demonstrates how you can implement custom URL handling (WebView, custom browser, etc.)

## How It Works

1. **Provider Configuration**: Two Stripe providers are configured - one for Payment Sheet and one for Payment Links
2. **Dynamic Selection**: Users can choose their preferred payment method
3. **Single API**: The same `SmartPay.checkout()` call works for both providers
4. **URL Handling**: Payment Links with manual handling return the URL for custom processing

## Environment Security

- **Development**: Use test keys (`pk_test_` and `sk_test_`) - safe to use in examples
- **Production**: Never include secret keys in client-side code - use backend callbacks instead

## Troubleshooting

### "Please set STRIPE_PUBLISHABLE_KEY and STRIPE_SECRET_KEY in your .env file"
- Make sure your `.env` file exists in the `example/` directory
- Verify your keys are properly set without extra spaces or quotes
- Ensure you're using test keys that start with `pk_test_` and `sk_test_`

### Payment Link creation fails
- Verify your secret key is correct and active
- Make sure you're in test mode in your Stripe dashboard
- Check your Stripe dashboard logs for more details

### App crashes on startup
- Run `flutter clean && flutter pub get` to refresh dependencies
- Make sure your `.env` file is properly formatted
- Check that flutter_dotenv is properly configured in `pubspec.yaml`

## Next Steps

- Try different payment amounts and currencies
- Experiment with Payment Link configuration options
- Implement custom URL handling in the manual mode
- Set up webhooks for payment confirmation
- Move to production keys when ready to go live

For more information, see the main [SmartPay documentation](../README.md).