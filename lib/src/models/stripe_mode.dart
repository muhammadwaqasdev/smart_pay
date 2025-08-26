/// Stripe-specific payment modes
enum StripeMode {
  /// Use SDK (in-app payment UI)
  paymentSheet,

  /// Use URL (redirect to external Stripe-hosted page)
  paymentLink,
}
