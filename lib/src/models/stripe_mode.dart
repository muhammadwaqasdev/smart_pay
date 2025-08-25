/// Stripe-specific payment modes
enum StripeMode {
  /// Use Payment Sheet (in-app payment UI)
  paymentSheet,

  /// Use Payment Links (redirect to external Stripe-hosted page)
  paymentLink,
}
