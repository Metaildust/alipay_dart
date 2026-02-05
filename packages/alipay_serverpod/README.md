# alipay_serverpod

[![pub package](https://img.shields.io/pub/v/alipay_serverpod.svg)](https://pub.dev/packages/alipay_serverpod)

Serverpod integration for Alipay App Pay + QR Pay.

[中文文档](README.zh.md)

## Prerequisites

Before using this package, you need to complete the following steps on Alipay platforms.

### Step 1: Register Alipay Merchant Account

1. Go to [Alipay Merchant Platform](https://b.alipay.com/)
2. Register a merchant account (requires business license for enterprise, or personal real-name for individual)
3. Complete account verification

### Step 2: Sign Product Agreements

Sign the required payment products at [Alipay Merchant Platform - Product Center](https://b.alipay.com/page/product-mall/all-product):

| Feature | Product to Sign | Notes |
|---------|-----------------|-------|
| App Pay | **App Payment** (App支付) | For invoking Alipay app from your mobile app |
| QR Pay | **Face-to-Face Payment** (当面付) | For generating QR codes |

> **Note**: Product approval may take 1-3 business days.

### Step 3: Create Application on Open Platform

1. Go to [Alipay Open Platform Console](https://open.alipay.com/develop/manage)
2. Click **Create Application** → Select **Mobile/Web App**
3. Fill in basic information and submit for review
4. After approval, note down your **App ID**

### Step 4: Configure Keys

1. In your application page, go to **Development Settings** → **Interface Signing Method**
2. Choose **Self-upload Public Key** mode
3. Generate RSA2 key pair (2048-bit):

```bash
# Generate private key
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out private_key.pem

# Export public key
openssl rsa -in private_key.pem -pubout -out public_key.pem

# Get public key string (upload this to Alipay)
grep -v "^-----" public_key.pem | tr -d '\n' && echo

# Get private key string for passwords.yaml (Base64 DER format)
openssl rsa -in private_key.pem -outform DER | base64
```

4. Upload the public key string to Alipay console
5. Download the **Alipay Public Key** (支付宝公钥) from console after upload
6. Save both keys for configuration below

> **Official Docs**: [Key Configuration Guide](https://opendocs.alipay.com/common/02kipl)

### Step 5: Bind Products to Application

1. In your application page, go to **Product bindng** (产品绑定)
2. Add the products you signed in Step 2

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

| Issue | Error Code | Cause | Fix |
|-------|------------|-------|-----|
| Missing passwords | - | Keys not in `passwords.yaml` | Add `alipayRsa2PrivateKey` and `alipayPublicKey` |
| Invalid signature | `isv.invalid-signature` / `40002` | Private key doesn't match public key on Alipay | Re-upload public key to Alipay console, ensure private key matches |
| Insufficient permissions | `isv.insufficient-isv-permissions` / `40006` | Product not signed or not bound | Sign product at [Merchant Platform](https://b.alipay.com/), bind to app at [Open Platform](https://open.alipay.com/) |
| App ID not found | `isv.invalid-app-id` | Wrong App ID or app not approved | Check App ID, ensure app status is "Online" |
| Notify not triggered | - | URL unreachable | Ensure HTTPS with valid certificate, public network access |
| Base64 decode error | `FormatException: Invalid padding` | Extra characters in private key | Remove trailing whitespace/newlines from key string |

### Common Configuration Errors

**1. Key Mismatch (isv.invalid-signature)**

The most common error. Verify your keys match:

```bash
# Export public key from your private key
echo "YOUR_PRIVATE_KEY_BASE64" | base64 -d | openssl rsa -inform DER -pubout

# Compare with public key on Alipay console - they must be identical
```

**2. Product Not Bound (40006)**

1. Check [Merchant Platform](https://b.alipay.com/) → Products → Ensure product is signed
2. Check [Open Platform](https://open.alipay.com/) → Your App → Product Binding → Ensure product is added

**3. Wrong Key Format**

- `alipayRsa2PrivateKey`: Base64 encoded DER format (single line, no PEM headers)
- `alipayPublicKey`: Base64 encoded DER format from Alipay console (NOT your public key)

## Related Packages

- [alipay](https://pub.dev/packages/alipay)
- [alipay_app](https://pub.dev/packages/alipay_app)
- [alipay_qr](https://pub.dev/packages/alipay_qr)

## License

MIT License
