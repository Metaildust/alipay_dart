import 'package:serverpod/serverpod.dart';

import 'alipay_notification.dart';

typedef OnAlipayPaymentSuccess = Future<void> Function(
  Session session,
  AlipayNotification notification,
);

typedef OnAlipayPaymentFailed = Future<void> Function(
  Session session,
  Object error,
  StackTrace stackTrace,
  Map<String, String> rawParams,
);
