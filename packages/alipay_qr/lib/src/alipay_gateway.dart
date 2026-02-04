import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/alipay_qr_exception.dart';

class AlipayGateway {
  static Future<Map<String, dynamic>> post(
    String gatewayUrl, {
    required Map<String, String> payload,
  }) async {
    final response = await http.post(
      Uri.parse(gatewayUrl),
      headers: const {
        'content-type': 'application/x-www-form-urlencoded;charset=utf-8',
      },
      body: payload,
    );
    if (response.statusCode != 200) {
      throw AlipayQrException(
        'Alipay gateway request failed: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw AlipayQrException('Invalid Alipay gateway response');
  }
}
