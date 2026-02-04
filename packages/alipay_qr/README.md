# alipay_qr

[![pub package](https://img.shields.io/pub/v/alipay_qr.svg)](https://pub.dev/packages/alipay_qr)

Alipay QR Pay precreate & query for Dart/Flutter (server-side).

[中文文档](README.zh.md)

> **Security Notice**: This package requires your Alipay private key and should only run on a trusted server. Do NOT embed private keys in client apps.

## Features

- **QR Precreate** - `alipay.trade.precreate` to generate QR code URL
- **Order Query** - `alipay.trade.query` to check payment status
- **RSA2 Signing** - Sign requests with PKCS#8 private key
- **Pure Dart** - No Flutter dependency

## Installation

```yaml
dependencies:
  alipay_qr: ^0.1.0
```

## Quick Start

```dart
import 'package:alipay_qr/alipay_qr.dart';

Future<void> main() async {
  final config = AlipayQrConfig(
    appId: '2021006129696450',
    privateKeyPem: '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----',
    notifyUrl: 'https://your-server/alipay/notify',
  );

  final client = AlipayQrClient(config);

  final precreate = await client.precreate(
    outTradeNo: 'order_20260204_0002',
    totalAmount: '10.00',
    subject: 'QR Pay Test',
  );
  print(precreate.qrCode);

  final status = await client.query(outTradeNo: precreate.outTradeNo);
  print(status.tradeStatus);
}
```

## Configuration

| Parameter | Required | Description | Default |
|----------|----------|-------------|---------|
| `appId` | Yes | Alipay App ID | - |
| `privateKeyPem` | Yes | PKCS#8 RSA private key | - |
| `notifyUrl` | Yes | Async notify callback URL | - |
| `charset` | No | Request charset | `utf-8` |
| `format` | No | Response format | `JSON` |
| `signType` | No | Signature type | `RSA2` |
| `version` | No | API version | `1.0` |
| `timeoutExpress` | No | Order timeout | `30m` |
| `gatewayUrl` | No | Gateway URL | `https://openapi.alipay.com/gateway.do` |

## API Reference

### AlipayQrClient

```dart
final precreate = await client.precreate(
  outTradeNo: 'order_001',
  totalAmount: '10.00',
  subject: 'Test Order',
);

final status = await client.query(outTradeNo: 'order_001');
```

### PrecreateOrder

Fields:
- `qrCode`
- `outTradeNo`
- `totalAmount`
- `tradeNo`

### OrderQueryResult

Fields:
- `outTradeNo`
- `tradeNo`
- `tradeStatus`
- `totalAmount`
- `paid`

## Troubleshooting

| Issue | Cause | Fix |
|------|-------|-----|
| Precreate failed | Invalid params or key | Check `appId`/`privateKeyPem` and amount format |
| Query returns empty status | Order not created | Ensure `outTradeNo` is correct |
| HTTP 4xx/5xx | Network or gateway error | Retry and check Alipay gateway status |

## Related Packages

- [alipay_app](https://pub.dev/packages/alipay_app) - App Pay order builder
- [alipay](https://pub.dev/packages/alipay) - Combined package
- [alipay_serverpod](https://pub.dev/packages/alipay_serverpod) - Serverpod integration

## License

MIT License
