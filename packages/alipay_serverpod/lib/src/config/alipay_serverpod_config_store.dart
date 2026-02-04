import 'alipay_app_config_serverpod.dart';
import 'alipay_password_keys.dart';

/// Global configuration store for Serverpod integration.
///
/// Call [configure] in `server.dart` before starting Serverpod.
class AlipayServerpodConfigStore {
  static AlipayAppConfigServerpod? _appConfig;
  static AlipayPasswordKeys _passwordKeys = const AlipayPasswordKeys();

  static void configure({
    required AlipayAppConfigServerpod appConfig,
    AlipayPasswordKeys passwordKeys = const AlipayPasswordKeys(),
  }) {
    _appConfig = appConfig;
    _passwordKeys = passwordKeys;
  }

  static AlipayAppConfigServerpod get appConfig {
    final config = _appConfig;
    if (config == null) {
      throw StateError(
        'AlipayServerpodConfigStore not configured. '
        'Call configure() in server.dart before using Alipay endpoints/routes.',
      );
    }
    return config;
  }

  static AlipayPasswordKeys get passwordKeys => _passwordKeys;
}
