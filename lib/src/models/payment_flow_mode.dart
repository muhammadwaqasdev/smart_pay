enum PaymentFlowMode {
  /// Choose backend if callbacks provided; otherwise attempt in-package if possible.
  auto,

  /// Force using backend-provided flow (e.g., your server creates intents/orders).
  backend,

  /// Force testing REST flow (only recommended for dev/sandbox).
  testing,
}
