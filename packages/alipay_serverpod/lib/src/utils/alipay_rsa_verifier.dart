import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart' as pc;

class AlipayRsaVerifier {
  bool verify({
    required String signContent,
    required String signatureBase64,
    required String publicKeyBase64,
  }) {
    try {
      final publicKey = _parsePublicKeyFromBase64(publicKeyBase64);
      final signer = pc.Signer('SHA-256/RSA');
      signer.init(false, pc.PublicKeyParameter<pc.RSAPublicKey>(publicKey));
      final signatureBytes = base64.decode(signatureBase64);
      final messageBytes = utf8.encode(signContent);
      return signer.verifySignature(
        messageBytes,
        pc.RSASignature(signatureBytes),
      );
    } catch (_) {
      return false;
    }
  }

  pc.RSAPublicKey _parsePublicKeyFromBase64(String publicKeyBase64) {
    final bytes = base64.decode(publicKeyBase64);
    final asn1Parser = ASN1Parser(bytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    final publicKeyBitString = topLevelSeq.elements![1] as ASN1BitString;
    final publicKeyAsn = ASN1Parser(
      publicKeyBitString.stringValues as Uint8List,
    );
    final publicKeySeq = publicKeyAsn.nextObject() as ASN1Sequence;
    final modulus = (publicKeySeq.elements![0] as ASN1Integer).integer;
    final exponent = (publicKeySeq.elements![1] as ASN1Integer).integer;
    return pc.RSAPublicKey(modulus!, exponent!);
  }
}
