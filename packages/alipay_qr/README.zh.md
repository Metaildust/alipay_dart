# alipay_qr

[![pub package](https://img.shields.io/pub/v/alipay_qr.svg)](https://pub.dev/packages/alipay_qr)

用于支付宝扫码支付预下单与订单查询的 Dart 包（服务端使用）。

[English](README.md)

> **安全提示**：本包需要使用支付宝私钥，仅适用于服务端或可信环境，切勿把私钥放在客户端应用中。

## 功能特性

- **扫码预下单** - `alipay.trade.precreate` 获取二维码地址
- **订单查询** - `alipay.trade.query` 查询支付状态
- **RSA2 签名** - 支持 PKCS#8 私钥签名
- **纯 Dart** - 无 Flutter 依赖

## 安装

```yaml
dependencies:
  alipay_qr: ^0.1.0
```

## 快速开始

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
    subject: '扫码支付测试',
  );
  print(precreate.qrCode);

  final status = await client.query(outTradeNo: precreate.outTradeNo);
  print(status.tradeStatus);
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
| `timeoutExpress` | 否 | 订单超时 | `30m` |
| `gatewayUrl` | 否 | 网关地址 | `https://openapi.alipay.com/gateway.do` |

## API 参考

### AlipayQrClient

```dart
final precreate = await client.precreate(
  outTradeNo: 'order_001',
  totalAmount: '10.00',
  subject: '测试订单',
);

final status = await client.query(outTradeNo: 'order_001');
```

### PrecreateOrder

字段：
- `qrCode`
- `outTradeNo`
- `totalAmount`
- `tradeNo`

### OrderQueryResult

字段：
- `outTradeNo`
- `tradeNo`
- `tradeStatus`
- `totalAmount`
- `paid`

## 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 预下单失败 | 参数或私钥错误 | 检查 `appId`/`privateKeyPem` 和金额格式 |
| 查询返回空状态 | 订单未创建 | 确认 `outTradeNo` 是否正确 |
| HTTP 4xx/5xx | 网络或网关异常 | 重试并检查网关状态 |

## 相关包

- [alipay_app](https://pub.dev/packages/alipay_app) - App 支付订单构建
- [alipay](https://pub.dev/packages/alipay) - 复合包
- [alipay_serverpod](https://pub.dev/packages/alipay_serverpod) - Serverpod 集成包

## License

MIT License
