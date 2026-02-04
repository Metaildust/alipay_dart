import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../config/alipay_serverpod_config.dart';
import '../utils/alipay_rsa_verifier.dart';
import 'alipay_notify_callback.dart';
import 'alipay_notification.dart';

class AlipayNotifyRoute extends Route {
  AlipayNotifyRoute({
    required this.config,
    required this.onPaymentSuccess,
    this.onPaymentFailed,
  }) : super(methods: {Method.post});

  final AlipayServerpodConfig config;
  final OnAlipayPaymentSuccess onPaymentSuccess;
  final OnAlipayPaymentFailed? onPaymentFailed;

  final AlipayRsaVerifier _verifier = AlipayRsaVerifier();

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final bodyText = await request.readAsString();
    Map<String, String> params = {};
    if (bodyText.isNotEmpty) {
      params = Uri.splitQueryString(bodyText);
    }

    final sign = params['sign'];
    if (sign == null || sign.isEmpty) {
      session.log('Alipay notify missing sign');
      return _failure();
    }

    final signContent = _buildSignContent(params);
    final verified = _verifier.verify(
      signContent: signContent,
      signatureBase64: sign,
      publicKeyBase64: config.publicKeyBase64,
    );
    if (!verified) {
      session.log(
        'Alipay notify signature verification failed. '
        'out_trade_no=${params['out_trade_no']}, sign_type=${params['sign_type']}',
      );
      return _failure();
    }

    final tradeStatus = params['trade_status'];
    if (tradeStatus != 'TRADE_SUCCESS' && tradeStatus != 'TRADE_FINISHED') {
      session.log('Alipay notify ignored trade_status=$tradeStatus');
      return _success();
    }

    final outTradeNo = params['out_trade_no'];
    if (outTradeNo == null || outTradeNo.isEmpty) {
      session.log('Alipay notify missing out_trade_no');
      return _failure();
    }

    final passbackRaw = params['passback_params'];
    final passback = passbackRaw == null || passbackRaw.isEmpty
        ? const <String, String>{}
        : Uri.splitQueryString(Uri.decodeComponent(passbackRaw));

    final notification = AlipayNotification(
      outTradeNo: outTradeNo,
      tradeNo: params['trade_no'],
      tradeStatus: tradeStatus ?? 'TRADE_SUCCESS',
      totalAmount: params['total_amount'],
      buyerPayAmount: params['buyer_pay_amount'],
      receiptAmount: params['receipt_amount'],
      passbackParams: passback,
      rawParams: params,
    );

    try {
      await onPaymentSuccess(session, notification);
      return _success();
    } catch (e, st) {
      session.log(
        'Alipay notify handler failed: $e',
        exception: e,
        stackTrace: st,
      );
      if (onPaymentFailed != null) {
        await onPaymentFailed!(session, e, st, params);
      }
      return _failure();
    }
  }
}

String _buildSignContent(Map<String, String> params) {
  final keys =
      params.keys.where((k) => k != 'sign' && k != 'sign_type').toList()
        ..sort();
  return keys.map((k) => '$k=${params[k] ?? ''}').join('&');
}

Result _success() => Response.ok(
  body: Body.fromString('success', mimeType: MimeType.plainText),
);

Result _failure() => Response.ok(
  body: Body.fromString('failure', mimeType: MimeType.plainText),
);
