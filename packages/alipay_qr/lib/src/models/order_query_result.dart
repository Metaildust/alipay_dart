class OrderQueryResult {
  final String outTradeNo;
  final String? tradeNo;
  final String? tradeStatus;
  final String? totalAmount;
  final bool paid;

  const OrderQueryResult({
    required this.outTradeNo,
    required this.tradeNo,
    required this.tradeStatus,
    required this.totalAmount,
    required this.paid,
  });
}
