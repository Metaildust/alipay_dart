class AlipayNotification {
  final String outTradeNo;
  final String? tradeNo;
  final String tradeStatus;
  final String? totalAmount;
  final String? buyerPayAmount;
  final String? receiptAmount;
  final Map<String, String> passbackParams;
  final Map<String, String> rawParams;

  const AlipayNotification({
    required this.outTradeNo,
    required this.tradeStatus,
    required this.rawParams,
    this.tradeNo,
    this.totalAmount,
    this.buyerPayAmount,
    this.receiptAmount,
    this.passbackParams = const {},
  });

  bool get paid =>
      tradeStatus == 'TRADE_SUCCESS' || tradeStatus == 'TRADE_FINISHED';

  String? get effectiveAmount =>
      totalAmount ?? buyerPayAmount ?? receiptAmount;
}
