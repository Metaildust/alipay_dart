# alipay_serverpod

[![pub package](https://img.shields.io/pub/v/alipay_serverpod.svg)](https://pub.dev/packages/alipay_serverpod)

支付宝支付的 Serverpod 集成包（App 支付 + 扫码支付）。

[English](README.md)

## 功能特性

- **配置集成** - 敏感配置读 `passwords.yaml`，非敏感配置放在 `server.dart`
- **基类 Endpoint** - 内置 `AlipayPaymentBaseEndpoint`
- **回调路由** - 自动验签 + 回调注入
- **完整导出** - 重新导出 `alipay` 包全部 API

## 安装

```yaml
# gen_server/pubspec.yaml
dependencies:
  alipay_serverpod: ^0.1.0
```

## 配置

### passwords.yaml（敏感配置）

```yaml
shared:
  alipayRsa2PrivateKey: |
    -----BEGIN PRIVATE KEY-----
    ...你的私钥...
    -----END PRIVATE KEY-----
  alipayPublicKey: 'MIIBIjANBg...'  # Base64 DER 公钥
```

### server.dart（非敏感配置）

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

  // 添加回调路由（注入记账逻辑）
  final alipayConfig = AlipayConfigServerpod.fromServerpod(pod);
  pod.webServer.addRoute(
    AlipayNotifyRoute(
      config: alipayConfig,
      onPaymentSuccess: (session, notification) async {
        // 你的幂等记账逻辑
      },
    ),
    '/alipay/notify',
  );

  await pod.start();
}
```

## 快速开始

### 使用基类 Endpoint

```dart
import 'package:alipay_serverpod/alipay_serverpod.dart';

class PaymentEndpoint extends AlipayPaymentBaseEndpoint {
  Future<AppPayOrder> createOrder(Session session, int amountCents) async {
    return createAppPayOrder(
      session,
      amountCents,
      outTradeNo: 'order_001',
      subject: '充值',
      passbackParams: 'uid=123',
    );
  }
}
```

### 回调处理（幂等）

```dart
AlipayNotifyRoute(
  config: alipayConfig,
  onPaymentSuccess: (session, notification) async {
    if (!notification.paid) return;

    // 建议幂等处理
    // 1) 先查询 outTradeNo 是否已入账
    // 2) 未入账则进行余额变更
  },
);
```

## API 参考

### AlipayServerpodConfigStore

全局配置存储（非敏感配置）。

```dart
AlipayServerpodConfigStore.configure(
  appConfig: AlipayAppConfigServerpod(...),
);
```

### AlipayConfigServerpod

组合 `passwords.yaml` 与非敏感配置，生成 `AlipayServerpodConfig`。

### AlipayPaymentBaseEndpoint

包含快捷方法：
- `createAppPayOrder`
- `createQrOrder`
- `queryOrder`

### AlipayNotifyRoute

自动验签的回调路由，支持注入回调。

### AlipayNotification

已解析的回调数据，包含：
- `paid`
- `effectiveAmount`

## 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 找不到密码配置 | `passwords.yaml` 缺少键 | 添加 `alipayRsa2PrivateKey` 和 `alipayPublicKey` |
| 验签失败 | 公钥格式错误 | 使用支付宝控制台导出的 Base64 DER 公钥 |
| 回调未触发 | 回调地址不可达 | 确保公网 HTTPS 可访问 |

## 相关包

- [alipay](https://pub.dev/packages/alipay)
- [alipay_app](https://pub.dev/packages/alipay_app)
- [alipay_qr](https://pub.dev/packages/alipay_qr)

## License

MIT License
