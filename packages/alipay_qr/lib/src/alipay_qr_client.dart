import 'dart:convert';

import 'alipay_gateway.dart';
import 'alipay_qr_config.dart';
import 'alipay_rsa_signer.dart';
import 'models/alipay_qr_exception.dart';
import 'models/order_query_result.dart';
import 'models/precreate_order.dart';

class AlipayQrClient {
  AlipayQrClient(this.config);

  final AlipayQrConfig config;
  final AlipayRsaSigner _signer = AlipayRsaSigner();

  Future<PrecreateOrder> precreate({
    required String outTradeNo,
    required String totalAmount,
    required String subject,
    String? body,
    String? passbackParams,
    String? timeoutExpress,
  }) async {
    final bizContent = <String, dynamic>{
      'subject': subject,
      'out_trade_no': outTradeNo,
      'total_amount': totalAmount,
      'timeout_express': timeoutExpress ?? config.timeoutExpress,
      if (body != null && body.isNotEmpty) 'body': body,
    };
    final params = _buildGatewayParams(
      method: 'alipay.trade.precreate',
      notifyUrl: config.notifyUrl,
      bizContent: jsonEncode(bizContent),
      passbackParams: passbackParams,
    );

    final response = await _callGateway(params);
    final result =
        response['alipay_trade_precreate_response'] as Map<String, dynamic>?;
    if (result == null) {
      throw const AlipayQrException('Invalid precreate response');
    }
    final code = result['code']?.toString();
    if (code != '10000') {
      throw AlipayQrException(
        'Alipay precreate failed',
        code: code,
        subCode: result['sub_code']?.toString(),
        subMessage: _buildSubMessage(result),
      );
    }
    final qrCode = result['qr_code']?.toString();
    if (qrCode == null || qrCode.isEmpty) {
      throw const AlipayQrException('Missing qr_code in response');
    }

    return PrecreateOrder(
      qrCode: qrCode,
      outTradeNo: result['out_trade_no']?.toString() ?? outTradeNo,
      totalAmount: result['total_amount']?.toString() ?? totalAmount,
      tradeNo: result['trade_no']?.toString(),
    );
  }

  Future<OrderQueryResult> query({
    required String outTradeNo,
  }) async {
    final bizContent = jsonEncode({'out_trade_no': outTradeNo});
    final params = _buildGatewayParams(
      method: 'alipay.trade.query',
      notifyUrl: null,
      bizContent: bizContent,
      passbackParams: null,
    );

    final response = await _callGateway(params);
    final result =
        response['alipay_trade_query_response'] as Map<String, dynamic>?;
    if (result == null) {
      throw const AlipayQrException('Invalid query response');
    }
    final code = result['code']?.toString();
    if (code != '10000') {
      throw AlipayQrException(
        'Alipay query failed',
        code: code,
        subCode: result['sub_code']?.toString(),
        subMessage: _buildSubMessage(result),
      );
    }

    final tradeStatus = result['trade_status']?.toString();
    final paid =
        tradeStatus == 'TRADE_SUCCESS' || tradeStatus == 'TRADE_FINISHED';
    final totalAmount =
        result['total_amount']?.toString() ??
        result['buyer_pay_amount']?.toString();

    return OrderQueryResult(
      outTradeNo: result['out_trade_no']?.toString() ?? outTradeNo,
      tradeNo: result['trade_no']?.toString(),
      tradeStatus: tradeStatus,
      totalAmount: totalAmount,
      paid: paid,
    );
  }

  Map<String, String> _buildGatewayParams({
    required String method,
    required String? notifyUrl,
    required String bizContent,
    required String? passbackParams,
  }) {
    final params = <String, String>{
      'app_id': config.appId,
      'method': method,
      'format': config.format,
      'charset': config.charset,
      'sign_type': config.signType,
      'timestamp': _formatTimestamp(DateTime.now()),
      'version': config.version,
      'biz_content': bizContent,
    };
    if (notifyUrl != null && notifyUrl.isNotEmpty) {
      params['notify_url'] = notifyUrl;
    }
    if (passbackParams != null && passbackParams.isNotEmpty) {
      params['passback_params'] = Uri.encodeComponent(passbackParams);
    }
    return params;
  }

  Future<Map<String, dynamic>> _callGateway(
    Map<String, String> params,
  ) async {
    final signContent = _buildSignContent(params);
    final sign = _signer.sign(signContent, config.privateKeyPem);
    final payload = {...params, 'sign': sign};
    return AlipayGateway.post(config.gatewayUrl, payload: payload);
  }

  String _buildSignContent(Map<String, String> params) {
    final entries = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  String _formatTimestamp(DateTime time) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${time.year}-${two(time.month)}-${two(time.day)} '
        '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }

  String _buildSubMessage(Map<String, dynamic> result) {
    final msg = result['msg']?.toString() ?? '';
    final subMsg = result['sub_msg']?.toString() ?? '';
    if (subMsg.isEmpty) return msg;
    return '$msg $subMsg'.trim();
  }
}
