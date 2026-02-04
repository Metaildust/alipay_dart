/// Keys for sensitive configuration in passwords.yaml.
class AlipayPasswordKeys {
  /// PKCS#8 private key.
  final String privateKey;

  /// Alipay public key (Base64 DER, not PEM).
  final String publicKey;

  const AlipayPasswordKeys({
    this.privateKey = 'alipayRsa2PrivateKey',
    this.publicKey = 'alipayPublicKey',
  });
}
