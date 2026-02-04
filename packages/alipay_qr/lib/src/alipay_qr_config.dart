class AlipayQrConfig {
  final String appId;
  final String privateKeyPem;
  final String notifyUrl;

  /// Optional overrides.
  final String charset;
  final String format;
  final String signType;
  final String version;
  final String timeoutExpress;
  final String gatewayUrl;

  const AlipayQrConfig({
    required this.appId,
    required this.privateKeyPem,
    required this.notifyUrl,
    this.charset = 'utf-8',
    this.format = 'JSON',
    this.signType = 'RSA2',
    this.version = '1.0',
    this.timeoutExpress = '30m',
    this.gatewayUrl = 'https://openapi.alipay.com/gateway.do',
  });
}
