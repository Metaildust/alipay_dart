# alipay

[![pub package](https://img.shields.io/pub/v/alipay.svg)](https://pub.dev/packages/alipay)

**The recommended package** for Alipay App Pay + QR Pay.

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

# Export public key (upload this to Alipay)
openssl rsa -in private_key.pem -pubout -out public_key.pem
```

4. Upload the public key to Alipay console
5. Download the **Alipay Public Key** (支付宝公钥) from console after upload

> **Official Docs**: 
> - [Key Configuration Guide](https://opendocs.alipay.com/common/02kipl)
> - [App Pay API](https://opendocs.alipay.com/open/204/105051)
> - [Face-to-Face Payment API](https://opendocs.alipay.com/open/194/106078)

### Step 5: Bind Products to Application

1. In your application page, go to **Product binding** (产品绑定)
2. Add the products you signed in Step 2

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
