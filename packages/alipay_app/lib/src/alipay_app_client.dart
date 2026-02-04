import 'dart:convert';

import 'alipay_app_config.dart';
import 'alipay_order_builder.dart';
import 'alipay_rsa_signer.dart';
import 'models/app_pay_order.dart';

class AlipayAppClient {
  AlipayAppClient(this.config);

  final AlipayAppConfig config;
  final AlipayRsaSigner _signer = AlipayRsaSigner();

  /// Creates an App Pay order string for Alipay SDK.
  ///
  /// [passbackParams] will be URL-encoded and set as `passback_params`.
  AppPayOrder createAppPayOrder({
    required String outTradeNo,
    required String totalAmount,
    required String subject,
    String? body,
    String? passbackParams,
    String? productCode,
    String? timeoutExpress,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    final bizContent = <String, dynamic>{
      'subject': subject,
      'out_trade_no': outTradeNo,
      'total_amount': totalAmount,
      'product_code': productCode ?? config.productCode,
      'timeout_express': timeoutExpress ?? config.timeoutExpress,
      if (body != null && body.isNotEmpty) 'body': body,
    };

    final params = <String, String>{
      'app_id': config.appId,
      'method': 'alipay.trade.app.pay',
      'format': config.format,
      'charset': config.charset,
      'sign_type': config.signType,
      'timestamp': AlipayOrderBuilder.formatTimestamp(now),
      'version': config.version,
      'notify_url': config.notifyUrl,
      'biz_content': jsonEncode(bizContent),
    };
    if (passbackParams != null && passbackParams.isNotEmpty) {
      params['passback_params'] = Uri.encodeComponent(passbackParams);
    }

    final signContent = AlipayOrderBuilder.buildSignContent(params);
    final sign = _signer.sign(signContent, config.privateKeyPem);
    final orderString =
        AlipayOrderBuilder.buildOrderString({...params, 'sign': sign});

    return AppPayOrder(
      orderString: orderString,
      outTradeNo: outTradeNo,
      totalAmount: totalAmount,
      subject: subject,
      timestamp: now,
      passbackParams: passbackParams,
    );
  }
}
