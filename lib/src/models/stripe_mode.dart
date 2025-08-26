/// Stripe-specific payment modes
enum StripeMode {
  /// Use SDK (in-app payment UI)
  SDK,

  /// Use URL (redirect to external Stripe-hosted page)
  URL,
}
