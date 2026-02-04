class AlipayAppConfig {
  final String appId;
  final String privateKeyPem;
  final String notifyUrl;

  /// Optional overrides.
  final String charset;
  final String format;
  final String signType;
  final String version;
  final String productCode;
  final String timeoutExpress;

  const AlipayAppConfig({
    required this.appId,
    required this.privateKeyPem,
    required this.notifyUrl,
    this.charset = 'utf-8',
    this.format = 'JSON',
    this.signType = 'RSA2',
    this.version = '1.0',
    this.productCode = 'QUICK_MSECURITY_PAY',
    this.timeoutExpress = '30m',
  });
}
