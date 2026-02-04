class PrecreateOrder {
  final String qrCode;
  final String outTradeNo;
  final String totalAmount;
  final String? tradeNo;

  const PrecreateOrder({
    required this.qrCode,
    required this.outTradeNo,
    required this.totalAmount,
    this.tradeNo,
  });
}
