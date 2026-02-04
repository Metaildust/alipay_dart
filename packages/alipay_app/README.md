# alipay_app

[![pub package](https://img.shields.io/pub/v/alipay_app.svg)](https://pub.dev/packages/alipay_app)

Alipay App Pay order builder for Dart/Flutter (server-side).

[中文文档](README.zh.md)

> **Security Notice**: This package requires your Alipay private key and should only run on a trusted server. Do NOT embed private keys in client apps.

## Features

- **App Pay Order String** - Build `alipay.trade.app.pay` order strings for SDKs (e.g., tobias)
- **RSA2 Signing** - Sign with PKCS#8 private key
- **Passback Params** - Optional `passback_params` support
- **Pure Dart** - No Flutter dependency

## Installation

```yaml
dependencies:
  alipay_app: ^0.1.0
```

## Quick Start

```dart
import 'package:alipay_app/alipay_app.dart';

void main() {
  final config = AlipayAppConfig(
    appId: '2021006129696450',
    privateKeyPem: '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----',
    notifyUrl: 'https://your-server/alipay/notify',
  );

  final client = AlipayAppClient(config);
  final order = client.createAppPayOrder(
    outTradeNo: 'order_20260204_0001',
    totalAmount: '10.00',
    subject: 'Membership Recharge',
    passbackParams: 'uid=12345',
  );

  // Send order.orderString to your mobile app and call the Alipay SDK.
  print(order.orderString);
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
| `productCode` | No | Product code | `QUICK_MSECURITY_PAY` |
| `timeoutExpress` | No | Order timeout | `30m` |

## API Reference

### AlipayAppConfig

Configuration holder for app pay.

### AlipayAppClient

Create order strings.

```dart
final order = client.createAppPayOrder(
  outTradeNo: 'order_001',
  totalAmount: '10.00',
  subject: 'Test Order',
  passbackParams: 'uid=123',
);
```

### AppPayOrder

Fields:
- `orderString`
- `outTradeNo`
- `totalAmount`
- `subject`
- `timestamp`
- `passbackParams`

## Troubleshooting

| Issue | Cause | Fix |
|------|-------|-----|
| Signature verification failed | Wrong private key format | Ensure PKCS#8 PEM and remove extra whitespace |
| Notify not received | Unreachable `notifyUrl` | Use public HTTPS endpoint and check server logs |
| Invalid amount | Format incorrect | Use 2-decimal string like `10.00` |

## Related Packages

- [alipay_qr](https://pub.dev/packages/alipay_qr) - QR code precreate & query
- [alipay](https://pub.dev/packages/alipay) - Combined package
- [alipay_serverpod](https://pub.dev/packages/alipay_serverpod) - Serverpod integration

## License

MIT License
