/// Generic payment processing modes that can be used across different payment providers
enum PaymentMode {
  /// SDK mode: In-app payment UI provided by the payment provider's SDK
  /// Examples: Stripe Payment Sheet, PayPal native checkout, etc.
  sdk,

  /// URL mode: URL-based payment where the provider gives you a URL to handle
  /// Examples: Stripe Payment Links, PayPal hosted checkout pages, etc.
  url,
}
