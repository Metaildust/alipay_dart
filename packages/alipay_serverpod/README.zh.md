# alipay_serverpod

[![pub package](https://img.shields.io/pub/v/alipay_serverpod.svg)](https://pub.dev/packages/alipay_serverpod)

支付宝支付的 Serverpod 集成包（App 支付 + 扫码支付）。

[English](README.md)

## 前置条件

使用本包前，需要在支付宝平台完成以下配置。

### 第一步：注册支付宝商家账户

1. 访问 [支付宝商家平台](https://b.alipay.com/)
2. 注册商家账户（企业需营业执照，个人需实名认证）
3. 完成账户审核

### 第二步：签约支付产品

在 [支付宝商家平台 - 产品中心](https://b.alipay.com/page/product-mall/all-product) 签约所需产品：

| 功能 | 需签约产品 | 说明 |
|------|----------|------|
| App 支付 | **App支付** | 从 App 调起支付宝客户端支付 |
| 扫码支付 | **当面付** | 生成支付二维码 |

> **注意**：产品审核通常需要 1-3 个工作日。

### 第三步：在开放平台创建应用

1. 访问 [支付宝开放平台控制台](https://open.alipay.com/develop/manage)
2. 点击 **创建应用** → 选择 **移动应用/网页应用**
3. 填写基本信息并提交审核
4. 审核通过后，记录 **App ID**

### 第四步：配置密钥

1. 在应用详情页，进入 **开发设置** → **接口加签方式**
2. 选择 **自行上传公钥** 模式
3. 生成 RSA2 密钥对（2048 位）：

```bash
# 生成私钥
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out private_key.pem

# 导出公钥
openssl rsa -in private_key.pem -pubout -out public_key.pem

# 获取公钥字符串（上传到支付宝）
grep -v "^-----" public_key.pem | tr -d '\n' && echo

# 获取私钥字符串用于 passwords.yaml（Base64 DER 格式）
openssl rsa -in private_key.pem -outform DER | base64
```

4. 将公钥字符串上传到支付宝控制台
5. 上传后，从控制台下载 **支付宝公钥**
6. 保存两个密钥用于下方配置

> **官方文档**：[密钥配置指南](https://opendocs.alipay.com/common/02kipl)

### 第五步：绑定产品到应用

1. 在应用详情页，进入 **产品绑定**
2. 添加第二步签约的产品

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

| 问题 | 错误码 | 原因 | 解决方案 |
|------|-------|------|---------|
| 找不到密码配置 | - | `passwords.yaml` 缺少键 | 添加 `alipayRsa2PrivateKey` 和 `alipayPublicKey` |
| 签名无效 | `isv.invalid-signature` / `40002` | 私钥与支付宝上的公钥不匹配 | 重新上传公钥到支付宝控制台，确保私钥匹配 |
| 权限不足 | `isv.insufficient-isv-permissions` / `40006` | 产品未签约或未绑定 | 在 [商家平台](https://b.alipay.com/) 签约产品，在 [开放平台](https://open.alipay.com/) 绑定到应用 |
| App ID 无效 | `isv.invalid-app-id` | App ID 错误或应用未上线 | 检查 App ID，确保应用状态为"已上线" |
| 回调未触发 | - | 回调地址不可达 | 确保 HTTPS 证书有效，公网可访问 |
| Base64 解码错误 | `FormatException: Invalid padding` | 私钥有多余字符 | 删除密钥字符串末尾的空白/换行符 |

### 常见配置错误排查

**1. 密钥不匹配 (isv.invalid-signature)**

最常见的错误。验证密钥是否匹配：

```bash
# 从私钥导出公钥
echo "你的私钥Base64" | base64 -d | openssl rsa -inform DER -pubout

# 与支付宝控制台上的公钥对比 - 必须完全一致
```

**2. 产品未绑定 (40006)**

1. 检查 [商家平台](https://b.alipay.com/) → 产品中心 → 确保产品已签约
2. 检查 [开放平台](https://open.alipay.com/) → 你的应用 → 产品绑定 → 确保产品已添加

**3. 密钥格式错误**

- `alipayRsa2PrivateKey`：Base64 编码的 DER 格式（单行，无 PEM 头尾）
- `alipayPublicKey`：支付宝控制台提供的支付宝公钥（不是你的公钥）

## 相关包

- [alipay](https://pub.dev/packages/alipay)
- [alipay_app](https://pub.dev/packages/alipay_app)
- [alipay_qr](https://pub.dev/packages/alipay_qr)

## License

MIT License
