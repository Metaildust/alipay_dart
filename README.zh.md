# alipay

[![pub package](https://img.shields.io/pub/v/alipay.svg)](https://pub.dev/packages/alipay)

**推荐使用的复合包**，同时包含支付宝 App 支付与扫码支付。

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

# 导出公钥（上传到支付宝）
openssl rsa -in private_key.pem -pubout -out public_key.pem
```

4. 将公钥上传到支付宝控制台
5. 上传后，从控制台下载 **支付宝公钥**

> **官方文档**：
> - [密钥配置指南](https://opendocs.alipay.com/common/02kipl)
> - [App 支付 API](https://opendocs.alipay.com/open/204/105051)
> - [当面付 API](https://opendocs.alipay.com/open/194/106078)

### 第五步：绑定产品到应用

1. 在应用详情页，进入 **产品绑定**
2. 添加第二步签约的产品

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
