class AppPayOrder {
  final String orderString;
  final String outTradeNo;
  final String totalAmount;
  final String subject;
  final String? passbackParams;
  final DateTime timestamp;

  /// The content that was signed (for debugging).
  final String? signContent;

  const AppPayOrder({
    required this.orderString,
    required this.outTradeNo,
    required this.totalAmount,
    required this.subject,
    required this.timestamp,
    this.passbackParams,
    this.signContent,
  });
}
