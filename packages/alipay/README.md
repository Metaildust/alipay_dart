# alipay

[![pub package](https://img.shields.io/pub/v/alipay.svg)](https://pub.dev/packages/alipay)

**The recommended package** for Alipay App Pay + QR Pay.

[中文文档](README.zh.md)

## Why Use This Package?

This package bundles both App Pay and QR Pay in one dependency:

| What You Need | Use This Package |
|--------------|------------------|
| App Pay order string | ✅ Included (`alipay_app`) |
| QR precreate & query | ✅ Included (`alipay_qr`) |

> **You do NOT need to import sub-packages separately.** This package re-exports everything from `alipay_app` and `alipay_qr`.

## Features

- **App Pay** - Build `alipay.trade.app.pay` order strings
- **QR Pay** - Precreate QR code and query order status
- **RSA2 Signing** - Sign all requests with PKCS#8 private key
- **Pure Dart** - No Flutter dependency

## Installation

```yaml
dependencies:
  alipay: ^0.1.0
```

## Quick Start

### App Pay

```dart
import 'package:alipay/alipay.dart';

void main() {
  final appConfig = AlipayAppConfig(
    appId: '2021006129696450',
    privateKeyPem: '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----',
    notifyUrl: 'https://your-server/alipay/notify',
  );

  final client = AlipayAppClient(appConfig);
  final order = client.createAppPayOrder(
    outTradeNo: 'order_001',
    totalAmount: '10.00',
    subject: 'Recharge',
  );
  print(order.orderString);
}
```

### QR Pay

```dart
final qrConfig = AlipayQrConfig(
  appId: '2021006129696450',
  privateKeyPem: '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----',
  notifyUrl: 'https://your-server/alipay/notify',
);

final qrClient = AlipayQrClient(qrConfig);
final precreate = await qrClient.precreate(
  outTradeNo: 'order_002',
  totalAmount: '10.00',
  subject: 'QR Pay',
);
print(precreate.qrCode);
```

## Security Notice

This package requires your private key. It must be used on a trusted server.

If you are using Serverpod, consider the dedicated integration package:
`alipay_serverpod`.

## Related Packages

- [alipay_app](https://pub.dev/packages/alipay_app)
- [alipay_qr](https://pub.dev/packages/alipay_qr)
- [alipay_serverpod](https://pub.dev/packages/alipay_serverpod)

## License

MIT License
