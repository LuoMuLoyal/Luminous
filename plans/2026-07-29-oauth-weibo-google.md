# OAuth 扩展计划：微博 + Google

> 创建日期：2026-07-29
> 状态：待执行

## 1. 背景与目标

当前 OAuth 登录支持 QQ、微信、Apple 三方。其中微信（开放平台认证需付费）和 Apple（Apple Developer Program 年费 $99/yr）因资金原因暂时不启用，但代码保留以便未来资金到位后直接填入凭证启用。

**目标**：新增微博和 Google 两个免费 OAuth Provider，与现有的 QQ 一起构成当前阶段的三大登录入口。

### Provider 选择理由

| Provider | 费用 | 用户覆盖 | 协议 | 接入难度 |
|----------|------|----------|------|----------|
| QQ（已有） | 免费 | 国内主流 | OAuth 2.0 Code Flow | 已完成 |
| 微博 | 免费 | 国内主流 | OAuth 2.0 Code Flow | 低（与 QQ 几乎一致） |
| Google | 免费 | 国际化必备 | OAuth 2.0 Code Flow | 低（标准流程） |
| 微信（保留） | 付费 | 国内主流 | OAuth 2.0 | 代码已就绪，暂不启用 |
| Apple（保留） | 付费 | iOS 用户 | Sign in with Apple | 代码已就绪，暂不启用 |

## 2. 现有架构概览

### 后端 (Lucent)

```
src/modules/auth/
├── types/oauth.types.ts          # OAuthProviderName union type + OAuthProfile
├── providers/
│   ├── oauth-provider.interface.ts  # OAuthProvider 接口
│   ├── qq-oauth.provider.ts         # QQ Provider（最简参考实现）
│   ├── apple-oauth.provider.ts      # Apple Provider
│   └── wechat/                      # WeChat Provider（web + mobile）
├── dto/shared/oauth.dto.ts        # 各 Provider 的 Callback DTO
├── controllers/oauth.controller.ts # OAuth 端点
├── services/oauth/facade.service.ts # OAuth 编排层
├── services/auth.service.ts       # AuthService 委托给 facade
└── auth.module.ts                 # 模块注册

src/config/
├── services/oauth.config.ts       # OAuthConfig（各 Provider 的配置结构）
├── env/env-keys.enum.ts           # 环境变量枚举
└── env/environment.validation.ts  # 环境变量校验
```

**关键设计**：
- `OAuthProvider` 接口只有两个方法：`buildAuthorizeUrl(state, callbackUri?)` + `fetchProfile(credential)`
- `OAuthProviderName` 是 union type，新增 provider 需在此添加
- `UserIdentity.provider` 是 Prisma `String`（非 enum），**不需要数据库迁移**
- 配置通过环境变量注入，`onModuleInit` 检查是否配置完整，未配置只 warn 不阻断启动

### 前端 (Luminous)

```
lib/features/auth/
├── domain/
│   ├── entities/oauth_authorize.dart   # OAuthAuthorizeData
│   └── repositories/auth.dart          # AuthRepository 接口
├── data/
│   ├── datasources/auth.dart           # LucentAuthRepository（用 generated client）
│   └── providers/auth.dart             # Provider 注册
├── presentation/
│   ├── providers/oauth_login.dart      # OAuthLoginController + State
│   ├── pages/login.dart                # LoginPage（OAuth 按钮行 + 回调处理）
│   ├── routes.dart                     # GoRouter 路由（OAuth 回调深链接）
│   └── widgets/shared/
│       ├── oauth_panels.dart           # OAuthButtonRow（品牌色圆形按钮）
│       └── oauth_callback_parser.dart  # OAuthCallbackParser

lib/app/router.dart                     # Routes 常量（loginOauthWechat 等）
lib/l10n/src/auth_zh.arb / auth_en.arb  # l10n 片段文件
assets/icon/oauth/                      # OAuth 品牌 SVG 图标
```

## 3. 实施方案

### 3.1 后端 (Lucent) — 微博 Provider

#### 3.1.1 新增环境变量

**文件**：`src/config/env/env-keys.enum.ts`

在 `QQ_REDIRECT_URI` 之后添加：

```typescript
WEIBO_APP_ID = 'WEIBO_APP_ID',
WEIBO_APP_SECRET = 'WEIBO_APP_SECRET',
WEIBO_REDIRECT_URI = 'WEIBO_REDIRECT_URI',
```

#### 3.1.2 环境变量校验

**文件**：`src/config/env/environment.validation.ts`

在 `QQ_REDIRECT_URI` 之后添加：

```typescript
[EnvKey.WEIBO_APP_ID]: optionalString,
[EnvKey.WEIBO_APP_SECRET]: optionalString,
[EnvKey.WEIBO_REDIRECT_URI]: optionalUri,
```

#### 3.1.3 OAuth 配置

**文件**：`src/config/services/oauth.config.ts`

在 `OAuthConfig` interface 中添加 `weibo` 字段，在工厂函数中读取环境变量：

```typescript
export interface OAuthConfig {
  wechatWeb: OAuthProviderConfig;
  wechatMobile: Omit<OAuthProviderConfig, 'redirectUri'>;
  apple: { appId: string; jwksUrl: string; issuer: string };
  qq: OAuthProviderConfig;
  weibo: OAuthProviderConfig;  // ← 新增
  google: OAuthProviderConfig; // ← 新增（见 3.2.3）
}
```

#### 3.1.4 OAuth Provider 类型

**文件**：`src/modules/auth/types/oauth.types.ts`

添加微博常量并扩展 union type：

```typescript
export const OAUTH_PROVIDER_WEIBO = 'weibo';

export type OAuthProviderName =
  | typeof OAUTH_PROVIDER_WECHAT_WEB
  | typeof OAUTH_PROVIDER_WECHAT_MOBILE
  | typeof OAUTH_PROVIDER_APPLE
  | typeof OAUTH_PROVIDER_QQ
  | typeof OAUTH_PROVIDER_WEIBO      // ← 新增
  | typeof OAUTH_PROVIDER_GOOGLE;    // ← 新增（见 3.2.4）
```

#### 3.1.5 微博 Provider 实现

**新文件**：`src/modules/auth/providers/weibo-oauth.provider.ts`

参照 `qq-oauth.provider.ts` 实现，微博 OAuth 2.0 三步走：

| 步骤 | URL |
|------|-----|
| 授权 | `https://api.weibo.com/oauth2/authorize` |
| 换 Token | `https://api.weibo.com/oauth2/access_token` |
| 获取用户信息 | `https://api.weibo.com/2/users/show.json` |

```typescript
@Injectable()
export class WeiboOAuthProvider implements OAuthProvider, OnModuleInit {
  readonly provider = OAUTH_PROVIDER_WEIBO;

  // buildAuthorizeUrl: response_type=code, client_id, redirect_uri, state
  // fetchProfile:
  //   1. POST access_token (grant_type=authorization_code)
  //   2. GET users/show.json (uid + access_token)
  //   返回: { provider, providerUserId: uid, nickname, avatar, rawProfile }
  // onModuleInit: 检查 appId/appSecret/redirectUri 是否配置
}
```

**关键差异（与 QQ 对比）**：
- 微博 token 端点用 POST（QQ 用 GET）
- 微博返回 JSON（QQ 返回 query-string / JSONP）
- 微博用户信息字段名不同：`screen_name`（昵称）、`profile_image_url`（头像）、`gender`（m/f/n）

#### 3.1.6 微博 DTO

**文件**：`src/modules/auth/dto/shared/oauth.dto.ts`

与 QQ 完全一致的模式（code + state）：

```typescript
export class WeiboOAuthCallbackDto {
  @ApiProperty({ description: '微博授权码' })
  @IsString()
  @MaxLength(512)
  code!: string;

  @ApiProperty({ description: '授权时生成的 state' })
  @IsString()
  @MaxLength(512)
  state!: string;
}

export class WeiboOAuthAuthorizeDto {
  @ApiProperty({
    description: '微博授权完成后的客户端回跳地址',
    required: false,
    example: 'https://api.lumos.app/oauth/weibo',
  })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  callbackUri?: string;
}
```

#### 3.1.7 Controller 端点

**文件**：`src/modules/auth/controllers/oauth.controller.ts`

在 QQ 端点之后添加两个端点：

```typescript
// POST /api/v1/auth/oauth/weibo/authorize
@Post('oauth/weibo/authorize')
async createWeiboAuthorizeUrl(@Body() dto?: WeiboOAuthAuthorizeDto) { ... }

// POST /api/v1/auth/oauth/weibo/callback
@Post('oauth/weibo/callback')
async loginWithWechat(@Body() dto: WeiboOAuthCallbackDto, @Req() request) { ... }
```

#### 3.1.8 Facade Service

**文件**：`src/modules/auth/services/oauth/facade.service.ts`

注入 `WeiboOAuthProvider`，添加 `createWeiboAuthorizeUrl` + `loginWithWeibo` 方法。模式与 QQ 完全一致：createState → buildAuthorizeUrl / consumeState → fetchProfile → loginWithOAuthProfile。

#### 3.1.9 AuthService 委托

**文件**：`src/modules/auth/services/auth.service.ts`

添加 `createWeiboAuthorizeUrl` + `loginWithWeibo` 委托方法。

#### 3.1.10 Module 注册

**文件**：`src/modules/auth/auth.module.ts`

在 `providers` 数组中添加 `WeiboOAuthProvider`。

#### 3.1.11 单元测试

**新文件**：`src/modules/auth/providers/weibo-oauth.provider.spec.ts`

参照 `qq-oauth.provider.spec.ts` 覆盖：
- `buildAuthorizeUrl` 生成正确 URL
- `fetchProfile` 三步 API 调用链
- 未配置时抛 `ServiceUnavailableException`
- API 调用失败时的错误处理

---

### 3.2 后端 (Lucent) — Google Provider

#### 3.2.1 新增环境变量

**文件**：`src/config/env/env-keys.enum.ts`

```typescript
GOOGLE_CLIENT_ID = 'GOOGLE_CLIENT_ID',
GOOGLE_CLIENT_SECRET = 'GOOGLE_CLIENT_SECRET',
GOOGLE_REDIRECT_URI = 'GOOGLE_REDIRECT_URI',
```

#### 3.2.2 环境变量校验

**文件**：`src/config/env/environment.validation.ts`

```typescript
[EnvKey.GOOGLE_CLIENT_ID]: optionalString,
[EnvKey.GOOGLE_CLIENT_SECRET]: optionalString,
[EnvKey.GOOGLE_REDIRECT_URI]: optionalUri,
```

#### 3.2.3 OAuth 配置

**文件**：`src/config/services/oauth.config.ts`

在工厂函数中添加 `google` 字段（使用 `OAuthProviderConfig` 结构）。

#### 3.2.4 OAuth Provider 类型

**文件**：`src/modules/auth/types/oauth.types.ts`

```typescript
export const OAUTH_PROVIDER_GOOGLE = 'google';
```

扩展 `OAuthProviderName` union（已在 3.1.4 中包含）。

#### 3.2.5 Google Provider 实现

**新文件**：`src/modules/auth/providers/google-oauth.provider.ts`

参照 `qq-oauth.provider.ts` 实现，Google OAuth 2.0 三步走：

| 步骤 | URL |
|------|-----|
| 授权 | `https://accounts.google.com/o/oauth2/v2/auth` |
| 换 Token | `https://oauth2.googleapis.com/token` |
| 获取用户信息 | `https://www.googleapis.com/oauth2/v3/userinfo` |

```typescript
@Injectable()
export class GoogleOAuthProvider implements OAuthProvider, OnModuleInit {
  readonly provider = OAUTH_PROVIDER_GOOGLE;

  // buildAuthorizeUrl:
  //   response_type=code, client_id, redirect_uri,
  //   scope="openid email profile", state, access_type=offline, prompt=consent
  // fetchProfile:
  //   1. POST token (grant_type=authorization_code, client_id, client_secret, code, redirect_uri)
  //   2. GET userinfo (Bearer access_token)
  //   返回: { provider, providerUserId: sub, email, emailVerifiedAt, nickname: name, avatar: picture }
  // onModuleInit: 检查 clientId/clientSecret/redirectUri
}
```

**关键差异（与 QQ 对比）**：
- Google scope 为 `openid email profile`
- Google token 端点用 POST + `application/x-www-form-urlencoded`
- Google userinfo 返回 `sub`（用户唯一 ID）、`email`、`email_verified`、`name`、`picture`
- Google 会返回 `email`，可直接填充 `OAuthProfile.email` + `emailVerifiedAt`
- 需添加 `access_type=offline` 和 `prompt=consent` 参数以确保获取 refresh token 和用户同意

#### 3.2.6 Google DTO

**文件**：`src/modules/auth/dto/shared/oauth.dto.ts`

与 QQ/微博一致的模式（code + state）：

```typescript
export class GoogleOAuthCallbackDto {
  @ApiProperty({ description: 'Google 授权码' })
  @IsString()
  @MaxLength(512)
  code!: string;

  @ApiProperty({ description: '授权时生成的 state' })
  @IsString()
  @MaxLength(512)
  state!: string;
}

export class GoogleOAuthAuthorizeDto {
  @ApiProperty({
    description: 'Google 授权完成后的客户端回跳地址',
    required: false,
  })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  callbackUri?: string;
}
```

#### 3.2.7 Controller 端点

**文件**：`src/modules/auth/controllers/oauth.controller.ts`

```typescript
// POST /api/v1/auth/oauth/google/authorize
@Post('oauth/google/authorize')
async createGoogleAuthorizeUrl(@Body() dto?: GoogleOAuthAuthorizeDto) { ... }

// POST /api/v1/auth/oauth/google/callback
@Post('oauth/google/callback')
async loginWithGoogle(@Body() dto: GoogleOAuthCallbackDto, @Req() request) { ... }
```

#### 3.2.8 Facade Service + AuthService + Module

同微博模式：Facade 注入 Provider + 添加方法 → AuthService 委托 → Module 注册。

#### 3.2.9 单元测试

**新文件**：`src/modules/auth/providers/google-oauth.provider.spec.ts`

参照 `qq-oauth.provider.spec.ts` 覆盖完整流程。

---

### 3.3 后端 — i18n 键

**文件**：`Lucent/src/i18n/zh/auth.json` 和 `Lucent/src/i18n/en/auth.json`

确认已有通用的 `auth.oauth_provider_not_configured`、`auth.oauth_provider_unavailable`、`auth.oauth_code_invalid`、`auth.oauth_code_required` 键，微博和 Google 复用这些键，不需要新增。

---

### 3.4 OpenAPI 导出

**命令**：在 `Lucent/` 下执行 `pnpm export:openapi`

重新生成 `Lucent/docs/openapi.json`，包含新的微博和 Google 端点。

---

### 3.5 前端 (Luminous) — 生成 API 客户端

**命令**：在 `Luminous/` 下执行 `dart run scripts/bootstrap_generated_sources.dart`

重新生成 `generated/lucent_api/`，包含微博和 Google 的 DTO 和 API 方法。

---

### 3.6 前端 (Luminous) — Domain 层

#### 3.6.1 AuthRepository 接口

**文件**：`lib/features/auth/domain/repositories/auth.dart`

添加四个新方法：

```dart
Future<OAuthAuthorizeData> createWeiboAuthorizeUrl({String? callbackUri});
Future<AuthSession> loginWithWeibo({required String code, required String state});
Future<OAuthAuthorizeData> createGoogleAuthorizeUrl({String? callbackUri});
Future<AuthSession> loginWithGoogle({required String code, required String state});
```

#### 3.6.2 OAuthAuthorizeData

**文件**：`lib/features/auth/domain/entities/oauth_authorize.dart`

无需修改 — 已有的 `OAuthAuthorizeData` 适用于所有 Provider。

---

### 3.7 前端 (Luminous) — Data 层

#### 3.7.1 LucentAuthRepository 实现

**文件**：`lib/features/auth/data/datasources/auth.dart`

添加四个方法实现，模式与 QQ 完全一致（调用 generated client → 映射结果 → 持久化 session）：

```dart
@override
Future<OAuthAuthorizeData> createWeiboAuthorizeUrl({String? callbackUri}) async { ... }

@override
Future<AuthSession> loginWithWeibo({required String code, required String state}) async { ... }

@override
Future<OAuthAuthorizeData> createGoogleAuthorizeUrl({String? callbackUri}) async { ... }

@override
Future<AuthSession> loginWithGoogle({required String code, required String state}) async { ... }
```

---

### 3.8 前端 (Luminous) — Presentation 层

#### 3.8.1 OAuthLoginState + Controller

**文件**：`lib/features/auth/presentation/providers/oauth_login.dart`

在 `OAuthLoginState` 中添加微博和 Google 的状态字段：

```dart
// Weibo
final bool isStartingWeibo;
final bool isCompletingWeibo;
final String? weiboAuthorizeUrl;
final String? weiboState;

// Google
final bool isStartingGoogle;
final bool isCompletingGoogle;
final String? googleAuthorizeUrl;
final String? googleState;
```

在 `OAuthLoginController` 中添加方法（模式与 QQ 完全一致）：

```dart
Future<String?> startWeiboLogin({String? webCallbackUri}) async { ... }
Future<AuthSession?> completeWeiboLogin({required String code, required String state}) async { ... }
Future<String?> startGoogleLogin({String? webCallbackUri}) async { ... }
Future<AuthSession?> completeGoogleLogin({required String code, required String state}) async { ... }
```

#### 3.8.2 OAuth 品牌色

**文件**：`lib/features/auth/presentation/widgets/shared/oauth_panels.dart`

在 `OAuthBrandColors` 中添加：

```dart
/// Weibo red — #E6162D.
static const Color weibo = Color(0xFFE6162D);

/// Google multi-color (使用 Google 标志的四色 G, 背景白色, 图标用官方 SVG).
/// Google 品牌指南允许使用多色图标, 不使用单一品牌色背景。
static const Color google = Color(0xFF4285F4); // Google Blue, 作为按钮背景
```

**注意**：Google 的品牌图标是四色的（蓝/红/黄/绿），与 WeChat/QQ/Apple 的单色品牌不同。方案：
- 方案 A：使用 Google Blue `#4285F4` 作为按钮背景色 + 白色 G 图标（与其他按钮一致）
- 方案 B：使用白色背景 + 四色 Google G 图标（更符合 Google 品牌指南）
- **推荐方案 B**，但需要 `_OAuthCircleButton` 支持非白色前景图（不应用 `ColorFilter.mode(white)`）

#### 3.8.3 OAuthButtonRow 扩展

**文件**：`lib/features/auth/presentation/widgets/shared/oauth_panels.dart`

在 `OAuthButtonRow` 中添加微博和 Google 的回调输入区域，模式与 QQ 一致：
- `wechatCallbackController` / `qqCallbackController` 同理添加 `weiboCallbackController` / `googleCallbackController`
- 回调输入框 + 完成按钮
- 按钮行中添加微博和 Google 的圆形按钮

按钮排列顺序：`QQ → 微博 → Google`（微信和 Apple 保留但不展示，或灰显）

> **微信/Apple 按钮处理**：当前微信和 Apple 按钮在未配置时仍然展示但点击会报错。建议通过环境变量或后端配置接口控制按钮可见性，但这超出本计划范围。暂时的方案是在 `OAuthButtonRow` 中添加一个 `enabledProviders` 参数，由上层控制哪些按钮可见。

#### 3.8.4 LoginPage 扩展

**文件**：`lib/features/auth/presentation/pages/login.dart`

1. 添加 `weiboCode/weiboState` 和 `googleCode/googleState` 构造函数参数（用于深链接回调）
2. 添加 `weiboCallbackController` 和 `googleCallbackController`
3. 添加 `startWeiboLogin` / `completeWeiboLoginFromInput` / `startGoogleLogin` / `completeGoogleLoginFromInput` 方法
4. 在 `useEffect` 中处理微博和 Google 的深链接回调
5. 将新的 controller/状态传入 `OAuthButtonRow`

#### 3.8.5 路由

**文件**：`lib/features/auth/presentation/routes.dart`

添加微博和 Google 的 OAuth 回调路由：

```dart
@TypedGoRoute<LoginOauthWeiboRoute>(path: '/login/oauth/weibo')
class LoginOauthWeiboRoute extends GoRouteData with $LoginOauthWeiboRoute {
  const LoginOauthWeiboRoute({this.code, this.state, this.returnTo});
  final String? code;
  final String? state;
  final String? returnTo;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return fadePage(
      key: state.pageKey,
      child: LoginPage(weiboCode: code, weiboState: this.state, returnTo: returnTo),
    );
  }
}

@TypedGoRoute<LoginOauthGoogleRoute>(path: '/login/oauth/google')
class LoginOauthGoogleRoute extends GoRouterData with $LoginOauthGoogleRoute {
  const LoginOauthGoogleRoute({this.code, this.state, this.returnTo});
  final String? code;
  final String? state;
  final String? returnTo;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return fadePage(
      key: state.pageKey,
      child: LoginPage(googleCode: code, googleState: this.state, returnTo: returnTo),
    );
  }
}
```

**文件**：`lib/app/router.dart`

在 `Routes` 类中添加：

```dart
static const loginOauthWeibo = '/login/oauth/weibo';
static const loginOauthGoogle = '/login/oauth/google';
```

#### 3.8.6 回调 URI 构建

**文件**：`lib/features/auth/presentation/pages/login.dart`

添加 `webWeiboCallbackUri()` 和 `webGoogleCallbackUri()` 方法，模式与 `webQqCallbackUri()` 一致。

#### 3.8.7 OAuth 图标资源

**新文件**：
- `assets/icon/oauth/weibo.svg` — 微博品牌图标
- `assets/icon/oauth/google.svg` — Google G 图标

**文件**：`pubspec.yaml` — 确认新资源被 `assets/icon/oauth/` 通配符覆盖（如果已有通配符则无需修改）。

---

### 3.9 前端 (Luminous) — L10n

**文件**：`lib/l10n/src/auth_zh.arb` 和 `lib/l10n/src/auth_en.arb`

添加微博和 Google 的 l10n 键（参照 QQ 的模式）：

```json
// zh
"authWeiboSignIn": "微博登录",
"authWeiboCallbackLabel": "微博回调链接 / 授权码",
"authWeiboCallbackHint": "授权后粘贴回调链接",
"authWeiboCompleteAction": "完成微博登录",
"authWeiboBrowserOpenFailed": "无法打开微博授权页。",
"authWeiboAuthorizeOpened": "已在浏览器打开微博授权页。",
"authWeiboCallbackRequiredToast": "请先粘贴微博回调链接。",
"authWeiboCallbackInvalidToast": "微博回调链接缺少 code 或 state。",

"authGoogleSignIn": "Google 登录",
"authGoogleCallbackLabel": "Google 回调链接 / 授权码",
"authGoogleCallbackHint": "授权后粘贴回调链接",
"authGoogleCompleteAction": "完成 Google 登录",
"authGoogleBrowserOpenFailed": "无法打开 Google 授权页。",
"authGoogleAuthorizeOpened": "已在浏览器打开 Google 授权页。",
"authGoogleCallbackRequiredToast": "请先粘贴 Google 回调链接。",
"authGoogleCallbackInvalidToast": "Google 回调链接缺少 code 或 state。",
```

```json
// en
"authWeiboSignIn": "Sign in with Weibo",
"authWeiboCallbackLabel": "Weibo callback link / code",
"authWeiboCallbackHint": "Paste the callback URL after authorization",
"authWeiboCompleteAction": "Complete Weibo sign-in",
"authWeiboBrowserOpenFailed": "Could not open the Weibo authorization page.",
"authWeiboAuthorizeOpened": "Weibo authorization opened in your browser.",
"authWeiboCallbackRequiredToast": "Please paste the Weibo callback link first.",
"authWeiboCallbackInvalidToast": "The Weibo callback link is missing code or state.",

"authGoogleSignIn": "Sign in with Google",
"authGoogleCallbackLabel": "Google callback link / code",
"authGoogleCallbackHint": "Paste the callback URL after authorization",
"authGoogleCompleteAction": "Complete Google sign-in",
"authGoogleBrowserOpenFailed": "Could not open the Google authorization page.",
"authGoogleAuthorizeOpened": "Google authorization opened in your browser.",
"authGoogleCallbackRequiredToast": "Please paste the Google callback link first.",
"authGoogleCallbackInvalidToast": "The Google callback link is missing code or state.",
```

同时添加 identity provider 显示名：

```json
// zh
"authIdentityProviderWeibo": "微博",
"authIdentityProviderGoogle": "Google",
// en
"authIdentityProviderWeibo": "Weibo",
"authIdentityProviderGoogle": "Google",
```

**命令**：`dart scripts/arb_tools.dart merge` → `flutter gen-l10n`

---

### 3.10 前端 (Luminous) — build_runner

**命令**：`dart run build_runner build`（重新生成 `routes.g.dart` 等）

---

## 4. 数据库

**不需要迁移**。`UserIdentity.provider` 是 `String` 类型，不是 enum，新 provider 字符串 `'weibo'` 和 `'google'` 直接写入即可。

---

## 5. 微信/Apple 暂时禁用策略

当前微信和 Apple 的 Provider 代码完全保留，不删除。禁用方式：

### 方案 A（推荐）：前端控制可见性

在 `OAuthButtonRow` 中添加 `enabledProviders` 参数（`Set<String>`），只有在此集合中的 provider 才渲染按钮。由上层（`LoginPage`）通过环境配置或后端接口决定。

### 方案 B：后端配置接口

后端暴露 `GET /api/v1/auth/oauth/providers` 返回当前启用的 provider 列表，前端据此渲染。这更灵活但增加了一次网络请求。

**本计划采用方案 A**，在 `LoginPage` 中硬编码当前启用的 provider 列表 `{'qq', 'weibo', 'google'}`。未来启用微信/Apple 时只需修改此列表。如果需要更动态的控制，后续可升级为方案 B。

---

## 6. 第三方平台注册

### 6.1 微博开放平台

1. 访问 https://open.weibo.com/
2. 创建应用 → 获取 `App Key`（= appId）和 `App Secret`
3. 设置授权回调页 URL（= redirectUri）
4. 环境变量：`WEIBO_APP_ID`、`WEIBO_APP_SECRET`、`WEIBO_REDIRECT_URI`

### 6.2 Google Cloud Console

1. 访问 https://console.cloud.google.com/
2. 创建项目 → APIs & Services → Credentials → 创建 OAuth 2.0 Client ID
3. 设置 Authorized redirect URIs
4. 环境变量：`GOOGLE_CLIENT_ID`、`GOOGLE_CLIENT_SECRET`、`GOOGLE_REDIRECT_URI`

### 6.3 QQ 互联平台

已配置，保持现状。

---

## 7. 测试策略

### 7.1 后端单元测试

| 文件 | 覆盖范围 |
|------|----------|
| `weibo-oauth.provider.spec.ts` | buildAuthorizeUrl、fetchProfile 三步链、未配置处理、API 失败处理 |
| `google-oauth.provider.spec.ts` | 同上 |
| `oauth.controller.spec.ts` | 新增微博/Google 端点的路由和响应 |
| `facade.service.spec.ts` | 新增微博/Google 的 createState/consumeState/profile 流程 |

### 7.2 前端测试

| 文件 | 覆盖范围 |
|------|----------|
| `oauth_login_test.dart` | 微博/Google 的 startLogin + completeLogin 状态流转 |
| `login_test.dart` | 微博/Google 按钮渲染、回调输入、深链接处理 |
| `auth_test.dart`（datasource） | 微博/Google 的 repository 方法调用 generated client |

### 7.3 集成验证

- 后端：`pnpm test:ci` + `pnpm test:e2e:ci`
- 前端：`flutter test` + `flutter analyze`
- 跨项目：`pnpm export:openapi` → `dart run scripts/bootstrap_generated_sources.dart`

---

## 8. 执行顺序

```
Phase 1: 后端 (Lucent)
  1. env-keys.enum.ts + environment.validation.ts + oauth.config.ts
  2. oauth.types.ts (新增 provider 常量 + union type)
  3. weibo-oauth.provider.ts + spec
  4. google-oauth.provider.ts + spec
  5. oauth.dto.ts (新增 DTO)
  6. facade.service.ts (新增方法)
  7. auth.service.ts (委托方法)
  8. oauth.controller.ts (新增端点)
  9. auth.module.ts (注册 Provider)
  10. pnpm lint:check && pnpm typecheck && pnpm build && pnpm test
  11. pnpm export:openapi

Phase 2: 前端 (Luminous)
  12. dart run scripts/bootstrap_generated_sources.dart
  13. domain/repositories/auth.dart (接口)
  14. data/datasources/auth.dart (实现)
  15. presentation/providers/oauth_login.dart (State + Controller)
  16. presentation/widgets/shared/oauth_panels.dart (UI)
  17. presentation/pages/login.dart (集成)
  18. presentation/routes.dart + app/router.dart (路由)
  19. l10n/src/auth_zh.arb + auth_en.arb → merge → gen-l10n
  20. assets/icon/oauth/weibo.svg + google.svg
  21. dart run build_runner build
  22. flutter analyze && flutter test

Phase 3: 文档
  23. Lucent: docs/02-logs/migration-log/2026-07-29.md
  24. Lucent: docs/01-reference/environment.md + environment-variables.md
  25. Luminous: docs/03-logs/migration-log/2026-07-29.md
  26. Luminous: docs/02-reference/Localization.md
```

---

## 9. 文档更新清单

### Lucent

| 文档 | 更新内容 |
|------|----------|
| `docs/02-logs/migration-log/2026-07-29.md` | 新增微博 + Google OAuth Provider |
| `docs/01-reference/environment.md` | 新增 `WEIBO_*` / `GOOGLE_*` 环境变量说明 |
| `docs/01-reference/environment-variables.md` | 新增变量条目 |

### Luminous

| 文档 | 更新内容 |
|------|----------|
| `docs/03-logs/migration-log/2026-07-29.md` | 新增微博 + Google 登录入口 |
| `docs/02-reference/Localization.md` | 新增 `authWeibo*` / `authGoogle*` l10n 键 |
