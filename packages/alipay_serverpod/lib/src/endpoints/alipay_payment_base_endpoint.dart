import 'package:alipay/alipay.dart';
import 'package:serverpod/serverpod.dart';

import '../config/alipay_serverpod_config.dart';

/// Base endpoint with ready-to-use Alipay helpers.
abstract class AlipayPaymentBaseEndpoint extends Endpoint {
  AlipayServerpodConfig _config(Session session) {
    return AlipayConfigServerpod.fromSession(session);
  }

  /// Create an App Pay order string.
  AppPayOrder createAppPayOrder(
    Session session,
    int amountCents, {
    required String outTradeNo,
    required String subject,
    String? body,
    String? passbackParams,
  }) {
    _validateAmount(amountCents);
    final config = _config(session);
    final client = AlipayAppClient(config.appConfig);
    final totalAmount = _amountToYuanString(amountCents);
    return client.createAppPayOrder(
      outTradeNo: outTradeNo,
      totalAmount: totalAmount,
      subject: subject,
      body: body,
      passbackParams: passbackParams,
    );
  }

  /// Create a QR Pay precreate order.
  Future<PrecreateOrder> createQrOrder(
    Session session,
    int amountCents, {
    required String outTradeNo,
    required String subject,
    String? body,
    String? passbackParams,
  }) async {
    _validateAmount(amountCents);
    final config = _config(session);
    final client = AlipayQrClient(config.qrConfig);
    final totalAmount = _amountToYuanString(amountCents);
    return client.precreate(
      outTradeNo: outTradeNo,
      totalAmount: totalAmount,
      subject: subject,
      body: body,
      passbackParams: passbackParams,
    );
  }

  /// Query Alipay order status.
  Future<OrderQueryResult> queryOrder(
    Session session,
    String outTradeNo,
  ) {
    final config = _config(session);
    final client = AlipayQrClient(config.qrConfig);
    return client.query(outTradeNo: outTradeNo);
  }

  void _validateAmount(int amountCents) {
    if (amountCents <= 0) {
      throw ArgumentError('amountCents must be greater than 0');
    }
  }

  String _amountToYuanString(int amountCents) {
    return (amountCents / 100).toStringAsFixed(2);
  }
}
