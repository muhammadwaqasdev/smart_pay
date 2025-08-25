enum PaymentFlowMode {
  /// Testing mode - uses test keys and creates payment intents/links automatically
  testing,

  /// Production mode - uses your backend callbacks for security
  production,
}
