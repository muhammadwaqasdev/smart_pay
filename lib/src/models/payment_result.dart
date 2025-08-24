class PaymentResult {
  final bool success;
  final String providerId;
  final String? transactionId;
  final String? message;
  final Map<String, Object?>? raw;

  const PaymentResult({
    required this.success,
    required this.providerId,
    this.transactionId,
    this.message,
    this.raw,
  });

  factory PaymentResult.success({
    required String providerId,
    String? transactionId,
    String? message,
    Map<String, Object?>? raw,
  }) {
    return PaymentResult(
      success: true,
      providerId: providerId,
      transactionId: transactionId,
      message: message,
      raw: raw,
    );
  }

  factory PaymentResult.failure({
    required String providerId,
    String? message,
    Map<String, Object?>? raw,
  }) {
    return PaymentResult(
      success: false,
      providerId: providerId,
      message: message,
      raw: raw,
    );
  }

  @override
  String toString() {
    return 'PaymentResult(success: '
        '$success, providerId: $providerId, transactionId: $transactionId, message: $message)';
  }
}
