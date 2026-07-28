# 第三方 SDK 清单

最后更新：2026-07-21

## 说明

为提供完整的用户体验，Luminous 使用了以下第三方 SDK。本清单依据《工业和信息化部 关于开展信息通信服务感知提升行动的通知》要求进行公示。

## SDK 清单

### 1. Flutter 框架

- **提供方**：Google LLC
- **用途**：应用基础框架，提供跨平台 UI 渲染
- **收集信息**：设备型号、操作系统版本（用于应用运行）
- **隐私政策**：https://flutter.dev/security

### 2. Sentry SDK

- **提供方**：Functional Software, Inc. (Sentry)
- **用途**：崩溃监控与错误追踪
- **收集信息**：设备型号、操作系统版本、应用崩溃日志、IP 地址
- **隐私政策**：https://sentry.io/privacy/

### 3. Dio（HTTP 客户端）

- **提供方**：Dart 开源社区
- **用途**：网络请求处理
- **收集信息**：不主动收集个人信息（仅作为网络通信库）

### 4. fluwx（微信 SDK）

- **提供方**：深圳市腾讯计算机系统有限公司
- **用途**：微信登录、分享功能
- **收集信息**：设备标识符、微信 OpenID（仅在使用微信登录时）
- **隐私政策**：https://privacy.qq.com/

### 5. Sign in with Apple

- **提供方**：Apple Inc.
- **用途**：Apple 账号登录
- **收集信息**：Apple ID 标识符、邮箱（仅在使用 Apple 登录时）
- **隐私政策**：https://www.apple.com/legal/privacy/

### 6. flutter_local_notifications

- **提供方**：Dart 开源社区
- **用途**：本地通知与用药提醒推送
- **收集信息**：不主动收集个人信息（仅调用系统通知 API）

### 7. mobile_scanner

- **提供方**：Dart 开源社区
- **用途**：药品条码扫描
- **收集信息**：相机画面（仅在用户主动扫描时处理，不存储上传）

### 8. share_plus

- **提供方**：Dart 开源社区
- **用途**：分享诊所摘要 PDF 等内容到其他应用
- **收集信息**：不主动收集个人信息

### 9. google_mlkit_text_recognition

- **提供方**：Google LLC
- **用途**：OCR 文字识别（用于药品包装识别）
- **收集信息**：图片中的文字内容（仅在用户主动使用时本地处理，不上传至服务器）
- **隐私政策**：https://policies.google.com/privacy

## 更新说明

本清单将随着应用依赖的变化而更新。如发现遗漏或有疑问，请通过应用内"帮助与反馈"联系我们。
