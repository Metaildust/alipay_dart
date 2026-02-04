/// Non-sensitive configuration values.
///
/// Pass these directly in code instead of putting in passwords.yaml.
class AlipayAppConfigServerpod {
  /// Alipay App ID.
  final String appId;

  /// Async notify callback URL.
  final String notifyUrl;

  /// Optional overrides.
  final String charset;
  final String format;
  final String signType;
  final String version;
  final String productCode;
  final String timeoutExpress;
  final String gatewayUrl;

  const AlipayAppConfigServerpod({
    required this.appId,
    required this.notifyUrl,
    this.charset = 'utf-8',
    this.format = 'JSON',
    this.signType = 'RSA2',
    this.version = '1.0',
    this.productCode = 'QUICK_MSECURITY_PAY',
    this.timeoutExpress = '30m',
    this.gatewayUrl = 'https://openapi.alipay.com/gateway.do',
  });
}
