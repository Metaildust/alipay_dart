import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart' as pc;

class AlipayRsaSigner {
  String sign(String content, String privateKeyPem) {
    final privateKey = _parsePrivateKeyFromPem(privateKeyPem);
    final signer = pc.Signer('SHA-256/RSA');
    signer.init(true, pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey));
    final signature =
        signer.generateSignature(Uint8List.fromList(utf8.encode(content)))
            as pc.RSASignature;
    return base64.encode(signature.bytes);
  }

  pc.RSAPrivateKey _parsePrivateKeyFromPem(String pem) {
    final normalized = pem
        .replaceAll('-----BEGIN PRIVATE KEY-----', '')
        .replaceAll('-----END PRIVATE KEY-----', '')
        .replaceAll(RegExp(r'\s+'), '');
    final bytes = base64.decode(normalized);

    final asn1Parser = ASN1Parser(bytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    final privateKeyOctet = topLevelSeq.elements![2] as ASN1OctetString;
    final privateKeyBytes = privateKeyOctet.valueBytes!;
    final pkAsn1Parser = ASN1Parser(privateKeyBytes);
    final pkSeq = pkAsn1Parser.nextObject() as ASN1Sequence;

    final modulus = (pkSeq.elements![1] as ASN1Integer).integer!;
    final privateExponent = (pkSeq.elements![3] as ASN1Integer).integer!;
    final p = (pkSeq.elements![4] as ASN1Integer).integer!;
    final q = (pkSeq.elements![5] as ASN1Integer).integer!;

    return pc.RSAPrivateKey(modulus, privateExponent, p, q);
  }
}
