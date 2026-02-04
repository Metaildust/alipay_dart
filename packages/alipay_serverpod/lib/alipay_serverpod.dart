/// Alipay Serverpod integration.
///
/// ## Quick Start
///
/// 1. Put credentials in `config/passwords.yaml`:
///
/// ```yaml
/// shared:
///   alipayRsa2PrivateKey: |
///     -----BEGIN PRIVATE KEY-----
///     ...
///     -----END PRIVATE KEY-----
///   alipayPublicKey: 'MIIBIjANBg...'
/// ```
///
/// 2. Configure non-sensitive values in `server.dart`:
///
/// ```dart
/// import 'package:alipay_serverpod/alipay_serverpod.dart';
///
/// AlipayServerpodConfigStore.configure(
///   appConfig: AlipayAppConfigServerpod(
///     appId: '2021006129696450',
///     notifyUrl: 'https://your-server/alipay/notify',
///   ),
/// );
/// ```
library alipay_serverpod;

export 'package:alipay/alipay.dart';

export 'src/config/alipay_app_config_serverpod.dart';
export 'src/config/alipay_password_keys.dart';
export 'src/config/alipay_serverpod_config.dart';
export 'src/config/alipay_serverpod_config_store.dart';
export 'src/endpoints/alipay_payment_base_endpoint.dart';
export 'src/routes/alipay_notify_callback.dart';
export 'src/routes/alipay_notify_route.dart';
export 'src/routes/alipay_notification.dart';
