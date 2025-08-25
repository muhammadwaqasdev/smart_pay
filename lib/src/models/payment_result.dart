class PaymentResult {
  final bool success;
  final String providerId;
  final String? transactionId;
  final String? message;
  final Map<String, Object?>? raw;

  /// The payment URL (only present for URL-based payments with manual handling)
  final String? paymentUrl;

  const PaymentResult({
    required this.success,
    required this.providerId,
    this.transactionId,
    this.message,
    this.raw,
    this.paymentUrl,
  });

  factory PaymentResult.success({
    required String providerId,
    String? transactionId,
    String? message,
    Map<String, Object?>? raw,
    String? paymentUrl,
  }) {
    return PaymentResult(
      success: true,
      providerId: providerId,
      transactionId: transactionId,
      message: message,
      raw: raw,
      paymentUrl: paymentUrl,
    );
  }

  factory PaymentResult.failure({
    required String providerId,
    String? message,
    Map<String, Object?>? raw,
    String? paymentUrl,
  }) {
    return PaymentResult(
      success: false,
      providerId: providerId,
      message: message,
      raw: raw,
      paymentUrl: paymentUrl,
    );
  }

  @override
  String toString() {
    return 'PaymentResult(success: '
        '$success, providerId: $providerId, transactionId: $transactionId, message: $message)';
  }
}
