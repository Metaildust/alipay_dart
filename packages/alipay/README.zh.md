# alipay

[![pub package](https://img.shields.io/pub/v/alipay.svg)](https://pub.dev/packages/alipay)

**推荐使用的复合包**，同时包含支付宝 App 支付与扫码支付。

[English](README.md)

## 为什么用这个包？

一行依赖即可覆盖两种支付方式：

| 需求 | 使用此包 |
|------|----------|
| App 支付订单字符串 | ✅ 已包含（`alipay_app`） |
| 扫码预下单与查询 | ✅ 已包含（`alipay_qr`） |

> **无需额外引入子包**，本包已重新导出 `alipay_app` 和 `alipay_qr`。

## 功能特性

- **App 支付** - 构建 `alipay.trade.app.pay` 订单字符串
- **扫码支付** - 预下单获取二维码，查询订单状态
- **RSA2 签名** - 使用 PKCS#8 私钥签名
- **纯 Dart** - 无 Flutter 依赖

## 安装

```yaml
dependencies:
  alipay: ^0.1.0
```

## 快速开始

### App 支付

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
    subject: '充值',
  );
  print(order.orderString);
}
```

### 扫码支付

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
  subject: '扫码支付',
);
print(precreate.qrCode);
```

## 安全提示

本包需要使用支付宝私钥，必须在服务端或可信环境使用。

若使用 Serverpod，建议使用专用集成包：`alipay_serverpod`。

## 相关包

- [alipay_app](https://pub.dev/packages/alipay_app)
- [alipay_qr](https://pub.dev/packages/alipay_qr)
- [alipay_serverpod](https://pub.dev/packages/alipay_serverpod)

## License

MIT License
