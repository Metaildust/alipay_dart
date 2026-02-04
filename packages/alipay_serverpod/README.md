# alipay_serverpod

[![pub package](https://img.shields.io/pub/v/alipay_serverpod.svg)](https://pub.dev/packages/alipay_serverpod)

Serverpod integration for Alipay App Pay + QR Pay.

[中文文档](README.zh.md)

## Features

- **Config Integration** - Read sensitive keys from `passwords.yaml`, keep non-sensitive config in `server.dart`
- **Base Endpoint** - Ready-to-use `AlipayPaymentBaseEndpoint` helpers
- **Notify Route** - Signature verification and callback injection
- **Full Export** - Re-exports all APIs from `alipay`

## Installation

```yaml
# gen_server/pubspec.yaml
dependencies:
  alipay_serverpod: ^0.1.0
```

## Configuration

### passwords.yaml (credentials only)

```yaml
shared:
  alipayRsa2PrivateKey: |
    -----BEGIN PRIVATE KEY-----
    ...your private key...
    -----END PRIVATE KEY-----
  alipayPublicKey: 'MIIBIjANBg...'  # Base64 DER public key
```

### server.dart (non-sensitive config)

```dart
import 'package:alipay_serverpod/alipay_serverpod.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  AlipayServerpodConfigStore.configure(
    appConfig: AlipayAppConfigServerpod(
      appId: '2021006129696450',
      notifyUrl: 'https://your-server/alipay/notify',
    ),
  );

  // Add notify route with your accounting logic
  final alipayConfig = AlipayConfigServerpod.fromServerpod(pod);
  pod.webServer.addRoute(
    AlipayNotifyRoute(
      config: alipayConfig,
      onPaymentSuccess: (session, notification) async {
        // Your idempotent recharge logic here
      },
    ),
    '/alipay/notify',
  );

  await pod.start();
}
```

## Quick Start

### Using Base Endpoint

```dart
import 'package:alipay_serverpod/alipay_serverpod.dart';

class PaymentEndpoint extends AlipayPaymentBaseEndpoint {
  Future<AppPayOrder> createOrder(Session session, int amountCents) async {
    return createAppPayOrder(
      session,
      amountCents,
      outTradeNo: 'order_001',
      subject: 'Recharge',
      passbackParams: 'uid=123',
    );
  }
}
```

### Notify Callback (Idempotent)

```dart
AlipayNotifyRoute(
  config: alipayConfig,
  onPaymentSuccess: (session, notification) async {
    if (!notification.paid) return;

    // Idempotent logic recommended
    // 1) Check existing transaction by outTradeNo
    // 2) If not exists, apply balance change
  },
);
```

## API Reference

### AlipayServerpodConfigStore

Global config store for non-sensitive values.

```dart
AlipayServerpodConfigStore.configure(
  appConfig: AlipayAppConfigServerpod(...),
);
```

### AlipayConfigServerpod

Builds `AlipayServerpodConfig` by combining config + passwords.

### AlipayPaymentBaseEndpoint

Base endpoint with helper methods:
- `createAppPayOrder`
- `createQrOrder`
- `queryOrder`

### AlipayNotifyRoute

Signature-verified notify route with injected callbacks.

### AlipayNotification

Parsed notify payload with helper fields:
- `paid`
- `effectiveAmount`

## Troubleshooting

| Issue | Cause | Fix |
|------|-------|-----|
| Missing passwords | Keys not in `passwords.yaml` | Add `alipayRsa2PrivateKey` and `alipayPublicKey` |
| Signature verification failed | Public key format mismatch | Use Base64 DER public key from Alipay console |
| Notify not triggered | URL unreachable | Ensure HTTPS and public access |

## Related Packages

- [alipay](https://pub.dev/packages/alipay)
- [alipay_app](https://pub.dev/packages/alipay_app)
- [alipay_qr](https://pub.dev/packages/alipay_qr)

## License

MIT License
