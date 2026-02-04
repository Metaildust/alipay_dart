# alipay_app

[![pub package](https://img.shields.io/pub/v/alipay_app.svg)](https://pub.dev/packages/alipay_app)

用于生成支付宝 App 支付订单字符串的 Dart 包（服务端使用）。

[English](README.md)

> **安全提示**：本包需要使用支付宝私钥，仅适用于服务端或可信环境，切勿把私钥放在客户端应用中。

## 功能特性

- **App 支付订单字符串** - 构建 `alipay.trade.app.pay` 订单字符串，供 SDK 调起支付
- **RSA2 签名** - 支持 PKCS#8 私钥签名
- **回传参数** - 支持 `passback_params`
- **纯 Dart** - 无 Flutter 依赖

## 安装

```yaml
dependencies:
  alipay_app: ^0.1.0
```

## 快速开始

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
    subject: '会员充值',
    passbackParams: 'uid=12345',
  );

  // 将 order.orderString 下发给 App，并调用支付宝 SDK 支付
  print(order.orderString);
}
```

## 配置说明

| 参数 | 必填 | 说明 | 默认值 |
|------|------|------|-------|
| `appId` | 是 | 支付宝 AppId | - |
| `privateKeyPem` | 是 | PKCS#8 RSA 私钥 | - |
| `notifyUrl` | 是 | 支付异步回调地址 | - |
| `charset` | 否 | 请求字符集 | `utf-8` |
| `format` | 否 | 返回格式 | `JSON` |
| `signType` | 否 | 签名方式 | `RSA2` |
| `version` | 否 | API 版本 | `1.0` |
| `productCode` | 否 | 产品码 | `QUICK_MSECURITY_PAY` |
| `timeoutExpress` | 否 | 订单超时 | `30m` |

## API 参考

### AlipayAppConfig

App 支付配置类。

### AlipayAppClient

创建订单字符串。

```dart
final order = client.createAppPayOrder(
  outTradeNo: 'order_001',
  totalAmount: '10.00',
  subject: '测试订单',
  passbackParams: 'uid=123',
);
```

### AppPayOrder

字段：
- `orderString`
- `outTradeNo`
- `totalAmount`
- `subject`
- `timestamp`
- `passbackParams`

## 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 签名校验失败 | 私钥格式不正确 | 确保使用 PKCS#8 PEM 格式且无多余空格 |
| 回调未收到 | `notifyUrl` 不可达 | 使用公网 HTTPS 地址并检查服务端日志 |
| 金额无效 | 金额格式错误 | 使用两位小数，如 `10.00` |

## 相关包

- [alipay_qr](https://pub.dev/packages/alipay_qr) - 支付宝扫码预下单与查询
- [alipay](https://pub.dev/packages/alipay) - 复合包
- [alipay_serverpod](https://pub.dev/packages/alipay_serverpod) - Serverpod 集成包

## License

MIT License
