import 'package:alipay/alipay.dart';
import 'package:serverpod/serverpod.dart';

import 'alipay_app_config_serverpod.dart';
import 'alipay_password_keys.dart';
import 'alipay_serverpod_config_store.dart';

class AlipayServerpodConfig {
  final AlipayAppConfig appConfig;
  final AlipayQrConfig qrConfig;
  final String publicKeyBase64;

  const AlipayServerpodConfig({
    required this.appConfig,
    required this.qrConfig,
    required this.publicKeyBase64,
  });
}

/// Builds Alipay config by combining app config (non-sensitive)
/// with passwords.yaml (sensitive).
class AlipayConfigServerpod {
  /// Creates configuration from Serverpod Session.
  static AlipayServerpodConfig fromSession(
    Session session, {
    AlipayAppConfigServerpod? appConfig,
    AlipayPasswordKeys? passwordKeys,
  }) {
    final app = appConfig ?? AlipayServerpodConfigStore.appConfig;
    final keys = passwordKeys ?? AlipayServerpodConfigStore.passwordKeys;

    return AlipayServerpodConfig(
      appConfig: AlipayAppConfig(
        appId: app.appId,
        privateKeyPem: _getPasswordOrThrow(session, keys.privateKey),
        notifyUrl: app.notifyUrl,
        charset: app.charset,
        format: app.format,
        signType: app.signType,
        version: app.version,
        productCode: app.productCode,
        timeoutExpress: app.timeoutExpress,
      ),
      qrConfig: AlipayQrConfig(
        appId: app.appId,
        privateKeyPem: _getPasswordOrThrow(session, keys.privateKey),
        notifyUrl: app.notifyUrl,
        charset: app.charset,
        format: app.format,
        signType: app.signType,
        version: app.version,
        timeoutExpress: app.timeoutExpress,
        gatewayUrl: app.gatewayUrl,
      ),
      publicKeyBase64: _getPasswordOrThrow(session, keys.publicKey),
    );
  }

  /// Creates configuration from Serverpod instance.
  static AlipayServerpodConfig fromServerpod(
    Serverpod serverpod, {
    AlipayAppConfigServerpod? appConfig,
    AlipayPasswordKeys? passwordKeys,
  }) {
    final app = appConfig ?? AlipayServerpodConfigStore.appConfig;
    final keys = passwordKeys ?? AlipayServerpodConfigStore.passwordKeys;

    return AlipayServerpodConfig(
      appConfig: AlipayAppConfig(
        appId: app.appId,
        privateKeyPem: _getPasswordFromServerpodOrThrow(
          serverpod,
          keys.privateKey,
        ),
        notifyUrl: app.notifyUrl,
        charset: app.charset,
        format: app.format,
        signType: app.signType,
        version: app.version,
        productCode: app.productCode,
        timeoutExpress: app.timeoutExpress,
      ),
      qrConfig: AlipayQrConfig(
        appId: app.appId,
        privateKeyPem: _getPasswordFromServerpodOrThrow(
          serverpod,
          keys.privateKey,
        ),
        notifyUrl: app.notifyUrl,
        charset: app.charset,
        format: app.format,
        signType: app.signType,
        version: app.version,
        timeoutExpress: app.timeoutExpress,
        gatewayUrl: app.gatewayUrl,
      ),
      publicKeyBase64:
          _getPasswordFromServerpodOrThrow(serverpod, keys.publicKey),
    );
  }

  static String _getPasswordOrThrow(Session session, String key) {
    final value = session.serverpod.getPassword(key);
    if (value == null || value.isEmpty) {
      throw StateError('$key must be configured in passwords.yaml');
    }
    return value;
  }

  static String _getPasswordFromServerpodOrThrow(
    Serverpod serverpod,
    String key,
  ) {
    final value = serverpod.getPassword(key);
    if (value == null || value.isEmpty) {
      throw StateError('$key must be configured in passwords.yaml');
    }
    return value;
  }
}
