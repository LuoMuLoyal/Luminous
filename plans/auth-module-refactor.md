# 登录注册模块重构方案

> **日期**: 2026-07-10
> **状态**: 方案设计阶段，待确认后实施

---

## 一、现状诊断

### 1.1 模块规模

| 文件 | 行数 | 问题 |
|------|------|------|
| `login_page.dart` | **656** | God Widget：6 个 controller + ~150 行内联 helper + 3 个内联 OAuth Panel |
| `login_form_provider.dart` | **366** | 18 个状态字段、7 种登录方式、5 处重复 try/catch |
| `account_settings_page.dart` | 417 | 较大但结构尚可 |
| `account_settings_sections.dart` | 402 | 同上 |
| `account_provider.dart` | 273 | 微信三路绑定 60 行单方法 |
| `register_form_provider.dart` | 194 | 与 login/password_reset 80% 重复 |
| `password_reset_provider.dart` | 184 | 同上 |
| `remote_data_source.dart` | 357 | `writeSession` 重复 5 次 |
| **总计** | **~3000** | 含 8 个微信相关文件 |

### 1.2 核心问题（按严重程度排序）

#### 🔴 P0 — LoginPage 是 God Widget（656 行）

单个 `HookConsumerWidget` 承担了：
- 6 个 `TextEditingController` 生命周期管理
- ~150 行内联 helper 函数（OAuth 回调解析、导航、平台检测、URL 构建）
- 微信登录三平台 fallback 链（mobile → desktop → web），40 行
- QQ 登录完整流程
- Apple 登录完整流程
- 3 个内联 `StatelessWidget`/`StatefulWidget`（`_WechatOAuthPanel`、`_QqOAuthPanel`、`_AppleOAuthPanel`）
- `useEffect` 处理 OAuth 深链接回调

**根因**：OAuth 流程编排逻辑（平台选择、回调解析、导航）全部堆在 UI 层，而非 service 层。

#### 🔴 P0 — 三个表单 Provider 80% 代码重复

`LoginFormNotifier`、`RegisterFormNotifier`、`PasswordResetNotifier` 共享几乎完全相同的：

| 重复内容 | 出现次数 | 每处行数 |
|----------|----------|----------|
| `updateEmail/Password/Code/ConfirmPassword` | 3 | ~10 行 × 4 |
| `validate` + `validateEmailOnly` | 3 | ~25 行 |
| `sendCode` + 冷却计时器 | 3 | ~35 行 |
| `_fail` 错误处理模式 | 3 | ~10 行 |
| `build` + `ref.onDispose(disposeCooldown)` | 3 | ~5 行 |

**根因**：缺少基类，每个表单从零实现相同的状态更新 + 验证 + 验证码发送逻辑。

#### 🟡 P1 — LoginFormState 18 个字段膨胀

```
email, password, code, confirmPassword, wechatCallbackInput, qqCallbackInput,
mode, isSubmitting, isSendingCode, isStartingWechatLogin, isCompletingWechatLogin,
isStartingQqLogin, isCompletingQqLogin, isStartingAppleLogin,
cooldownSeconds, emailError, passwordError, codeError,
wechatAuthorizeUrl, wechatState, qqAuthorizeUrl, qqState, errorMessage
```

6 个 `is*Loading` 布尔位对应不同 OAuth 流程，新增登录方式需继续追加。

**根因**：OAuth 流程状态与表单字段状态混在同一个 state 对象中。

#### 🟡 P1 — OAuth try/catch 重复模式

`LoginFormNotifier` 中 5 个 OAuth 方法遵循完全相同的骨架：

```dart
Future<AuthSession?> someOAuthLogin() async {
  state = state.copyWith(isStartingXxxLogin: true, errorMessage: null);
  try {
    final session = await ref.read(authRemoteDataSourceProvider).loginWithXxx(...);
    await ref.read(authSessionProvider.notifier).applySession(session);
    state = state.copyWith(isStartingXxxLogin: false);
    return session;
  } catch (error) {
    final apiError = LucentErrorMapper.fromObject(error);
    state = state.copyWith(isStartingXxxLogin: false, errorMessage: apiError.message);
    return null;
  }
}
```

**根因**：缺少统一的 async action 管道（`account_provider.dart` 已有 `_run` helper 但 login 没有采用）。

#### 🟡 P1 — AuthRemoteDataSource writeSession 重复 5 次

```dart
final session = AuthMapper.toSessionFromLogin(response);
await _client.writeSession(
  LucentSessionTokens(
    accessToken: session.accessToken,
    refreshToken: session.refreshToken,
  ),
);
return session;
```

出现在 `login`、`loginWithWechatWeb`、`loginWithWechatMobile`、`loginWithApple`、`loginWithQq` 中。

#### 🟢 P2 — account_provider 微信三路绑定与 login 微信三路登录重复

`startWechatIdentityLink`（account_provider）和 `startWechatLogin`（login_page）都有 mobile → desktop → web 的三平台 fallback 链，且桌面流程都管理 `WechatDesktopOAuthCallbackServer` 生命周期。

---

## 二、重构方案

### 2.1 设计原则

1. **不引入新依赖** — 当前 `riverpod` + `freezed` + `fluwx` + `sign_in_with_apple` 已足够，问题在于代码组织而非缺少工具
2. **渐进式可落地** — 每一步独立可测，不要求一次性全部完成
3. **UI 层不做业务编排** — OAuth 平台选择、回调解析、导航决策属于 service 层

### 2.2 目标架构

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_remote_data_source.dart      ← 瘦身后：提取 _persistSession
│   │   └── wechat/
│   │       ├── wechat_desktop_oauth_server.dart  ← 不变
│   │       └── wechat_mobile_auth_client.dart    ← 不变
│   └── providers/
│       └── data_providers.dart               ← 不变
│
├── domain/
│   └── entities/
│       └── session.dart                      ← 不变
│
├── services/                                 ← 【新增层】
│   ├── oauth/
│   │   ├── oauth_provider.dart               ← sealed class: 统一 OAuth 接口
│   │   ├── wechat_oauth_service.dart         ← 微信三平台 fallback 编排
│   │   ├── qq_oauth_service.dart             ← QQ OAuth
│   │   └── apple_oauth_service.dart          ← Apple Sign In
│   ├── auth_action_runner.dart               ← 统一 async action 管道
│   └── oauth_callback_parser.dart            ← 回调 URL 解析（从 login_page 提取）
│
├── presentation/
│   ├── providers/
│   │   ├── forms/
│   │   │   ├── base_auth_form_notifier.dart  ← 【新增】共享基类
│   │   │   ├── login_form_provider.dart      ← 瘦身后 ~120 行
│   │   │   ├── register_form_provider.dart   ← 瘦身后 ~60 行
│   │   │   └── password_reset_provider.dart  ← 瘦身后 ~50 行
│   │   ├── session/
│   │   │   ├── session_provider.dart         ← 不变
│   │   │   └── account_provider.dart         ← 瘦身后 ~150 行
│   │   └── shared/
│   │       └── form_mixin.dart               ← 不变（被基类使用）
│   │
│   ├── pages/
│   │   ├── login_page.dart                   ← 瘦身后 ~150 行
│   │   ├── register_page.dart                ← 瘦身后 ~150 行
│   │   ├── forgot_password_page.dart         ← 瘦身后 ~120 行
│   │   └── ...
│   │
│   └── widgets/
│       ├── shared/
│       │   ├── shell.dart                    ← 不变
│       │   └── branding.dart                 ← 不变
│       └── auth/                             ← 【新增】从 login_page 提取
│           ├── oauth_buttons_section.dart     ← OAuth 按钮组
│           ├── verification_code_field.dart   ← 验证码输入 + 发送按钮（已有）
│           └── auth_form_fields.dart          ← 共享表单字段组件
```

### 2.3 分步实施计划

---

#### Step 1: 提取 `AuthActionRunner` — 统一 async action 管道

**目标**：消除 5 处 OAuth try/catch 重复 + 3 处表单 `_fail` 重复

**新文件**: `lib/features/auth/services/auth_action_runner.dart`

```dart
/// 统一的异步认证操作执行器。
///
/// 所有表单 notifier 通过此方法执行 API 调用，自动处理：
/// - loading 状态切换
/// - 错误映射（LucentErrorMapper）
/// - 日志记录
typedef AuthStateUpdater<T> = T Function(T current, {bool isSubmitting, String? errorMessage});

/// 在表单 notifier 中执行异步操作。
///
/// [setLoading] 设置 loading 标志位，[action] 是实际 API 调用。
/// 成功返回结果，失败返回 null 并设置 errorMessage。
Future<T?> runAuthAction<T>({
  required Notifier<T> notifier,
  required T Function(T current) setLoading,
  required T Function(T current, String error) setError,
  required Future<T> Function() action,
}) async {
  notifier.state = setLoading(notifier.state);
  try {
    final result = await action();
    return result;
  } catch (error) {
    final apiError = LucentErrorMapper.fromObject(error);
    notifier.state = setError(notifier.state, apiError.message);
    return null;
  }
}
```

**效果**：每个 OAuth 方法从 ~25 行减至 ~5 行

---

#### Step 2: 提取 `BaseAuthFormNotifier` — 消除三个表单 80% 重复

**目标**：`login`、`register`、`password_reset` 共享基类

**新文件**: `lib/features/auth/presentation/providers/forms/base_auth_form_notifier.dart`

```dart
/// 所有认证表单的共享基类。
///
/// 提供：字段更新、验证、验证码发送 + 冷却计时器、错误处理。
/// 子类只需定义自己的 State 类型（含 [BaseAuthFormFields] mixin）
/// 和 [submit] 方法。
abstract class BaseAuthFormNotifier<S extends BaseAuthFormState>
    extends Notifier<S> with CooldownTimerMixin<S> {
  
  @override
  S build() {
    ref.onDispose(disposeCooldown);
    return initialState();
  }
  
  S initialState();
  
  // ── 字段更新（子类通过 copyWith 实现） ──
  void updateEmail(String value);
  void updatePassword(String value);
  void updateCode(String value);
  void updateConfirmPassword(String value);
  
  // ── 验证码发送（共享逻辑） ──
  Future<bool> sendCode({
    required AuthVerificationScene scene,
  }) async {
    state = state.copyWithFields(isSendingCode: true, errorMessage: null);
    try {
      final result = await ref.read(authRemoteDataSourceProvider)
          .sendVerificationCode(email: state.email, scene: scene);
      final cooldown = result.cooldown.toInt();
      state = state.copyWithFields(isSendingCode: false, successMessage: result.message);
      startCooldown(cooldown, ...);
      return true;
    } catch (error) {
      state = state.copyWithFields(isSendingCode: false, errorMessage: ...);
      return false;
    }
  }
  
  // ── 错误处理 ──
  bool fail(Object error) {
    final apiError = LucentErrorMapper.fromObject(error);
    state = state.copyWithFields(
      isSubmitting: false,
      isSendingCode: false,
      errorMessage: apiError.message,
    );
    return false;
  }
}
```

**效果**：
- `RegisterFormNotifier` 从 194 行减至 ~60 行（只剩 `submit` + `validate`）
- `PasswordResetNotifier` 从 184 行减至 ~50 行
- `LoginFormNotifier` 的密码/验证码部分也复用基类

---

#### Step 3: 提取 `OAuthProvider` 策略 — 消除 OAuth 编排重复

**目标**：将微信三平台 fallback、QQ 流程、Apple 流程从 UI 层和 Provider 层提取到 service 层

**新文件**: `lib/features/auth/services/oauth/oauth_provider.dart`

```dart
/// 统一的 OAuth 提供者接口。
///
/// 每个第三方登录方式实现此接口。UI 层不需要知道平台细节。
sealed class OAuthProvider {
  /// 显示名称
  String get displayName;
  
  /// 当前平台是否支持原生 SDK（不需要浏览器）
  bool get isNativeSupported;
  
  /// 启动 OAuth 流程，返回 session 或 null（失败/取消）。
  ///
  /// 内部自动选择最佳平台策略（mobile SDK → desktop server → web URL）。
  Future<AuthSession?> startAuth(Ref ref);
  
  /// 对于 web fallback：创建授权 URL
  Future<OAuthAuthorizeDataDto?> createAuthorizeUrl(Ref ref, {String? callbackUri});
  
  /// 对于 web fallback：用回调 code 完成登录
  Future<AuthSession?> completeAuth(Ref ref, {required String code, required String state});
}
```

**新文件**: `lib/features/auth/services/oauth/wechat_oauth_service.dart`

```dart
class WechatOAuthService extends OAuthProvider {
  @override
  String get displayName => 'WeChat';
  
  @override
  bool get isNativeSupported {
    // 桌面有 callback server，移动有 fluwx SDK
    return WechatMobileAuthClient.isSupported || 
           WechatDesktopOAuthCallbackListener.isSupported;
  }
  
  @override
  Future<AuthSession?> startAuth(Ref ref) async {
    // 1. 尝试移动端 SDK
    final mobileClient = ref.read(wechatMobileAuthClientProvider);
    if (mobileClient.isSupported) {
      try {
        final code = await mobileClient.authorize();
        return await ref.read(authRemoteDataSourceProvider)
            .loginWithWechatMobile(code: code);
      } catch (_) { /* fall through */ }
    }
    
    // 2. 尝试桌面本地服务器
    final desktopListener = ref.read(wechatDesktopOAuthCallbackListenerProvider);
    if (desktopListener.isSupported) {
      return _startDesktopAuth(ref, desktopListener);
    }
    
    // 3. Web fallback — 返回 null，UI 层会展示授权 URL
    return null;
  }
  
  Future<AuthSession?> _startDesktopAuth(
    Ref ref,
    WechatDesktopOAuthCallbackListener listener,
  ) async {
    WechatDesktopOAuthCallbackServer? server;
    try {
      server = await listener.start();
      final authorize = await ref.read(authRemoteDataSourceProvider)
          .createWechatWebAuthorizeUrl(callbackUri: server.callbackUri.toString());
      
      final opened = await ref.read(externalUrlLauncherProvider)
          .open(Uri.parse(authorize.authorizeUrl));
      if (!opened) return null;
      
      final callback = await server.callback.timeout(
        Duration(seconds: authorize.expiresIn.toInt()),
      );
      if (callback.state != authorize.state) return null;
      
      return await ref.read(authRemoteDataSourceProvider)
          .loginWithWechatWeb(code: callback.code, state: callback.state);
    } finally {
      await server?.close();
    }
  }
  
  @override
  Future<OAuthAuthorizeDataDto?> createAuthorizeUrl(Ref ref, {String? callbackUri}) {
    return ref.read(authRemoteDataSourceProvider)
        .createWechatWebAuthorizeUrl(callbackUri: callbackUri);
  }
  
  @override
  Future<AuthSession?> completeAuth(Ref ref, {required String code, required String state}) {
    return ref.read(authRemoteDataSourceProvider)
        .loginWithWechatWeb(code: code, state: state);
  }
}
```

**效果**：
- `LoginFormNotifier` 中的 4 个微信方法 + 2 个 QQ 方法 + 1 个 Apple 方法全部删除
- `LoginPage` 中的 `startWechatLogin`（40 行）、`completeWechatLoginFromInput`、`startQqLogin`、`startAppleLogin` 全部删除
- `account_provider.dart` 中的微信三路绑定复用 `WechatOAuthService` 的平台检测逻辑

---

#### Step 4: 提取 `OAuthCallbackParser` — 从 login_page 提取回调解析

**目标**：将 40 行的 `parseWechatCallback` 从 UI 层移到 service 层

**新文件**: `lib/features/auth/services/oauth_callback_parser.dart`

```dart
/// 解析 OAuth 回调 URL 或原始输入。
///
/// 支持格式：
/// 1. 完整 URL: https://example.com/callback?code=xxx&state=yyy
/// 2. 查询参数: ?code=xxx&state=yyy
/// 3. 键值对: code=xxx&state=yyy
/// 4. 纯 code（需提供 fallbackState）
class OAuthCallbackParser {
  const OAuthCallbackParser();
  
  ({String code, String state})? parse(String raw, String? fallbackState) {
    // ... 从 login_page.dart 提取的解析逻辑
  }
}
```

---

#### Step 5: 提取 `AuthRemoteDataSource._persistSession` — 消除 5 次重复

**目标**：`writeSession` 逻辑只出现一次

```dart
class AuthRemoteDataSource {
  // ...
  
  /// 持久化 session token 到本地存储。
  Future<AuthSession> _persistSession(LoginResponseDto response) async {
    final session = AuthMapper.toSessionFromLogin(response);
    await _client.writeSession(
      LucentSessionTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
    return session;
  }
  
  Future<AuthSession> login({...}) async {
    final response = await _client.authApi.localControllerLoginV1(...);
    return _persistSession(response);
  }
  
  Future<AuthSession> loginWithWechatWeb({...}) async {
    final response = await _client.authApi.oAuthControllerLoginWithWechatWebV1(...);
    return _persistSession(response);
  }
  // ... 其余 3 个方法同理
}
```

---

#### Step 6: 分解 LoginPage — 从 656 行减至 ~150 行

**目标**：将 OAuth 编排逻辑移入 service 层后，LoginPage 只做 UI 组装

**重构后的 LoginPage 结构**：

```dart
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key, this.wechatCode, this.wechatState, this.qqCode, this.qqState, this.returnTo});
  
  // 4 个 OAuth 回调参数 + returnTo
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final codeController = useTextEditingController();
    
    final state = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    
    // OAuth 深链接回调处理 — 委托给 provider
    useEffect(() {
      if (wechatCode != null && wechatState != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifier.completeOAuthCallback(
            provider: OAuthProviderType.wechat,
            code: wechatCode!,
            state: wechatState!,
          );
        });
      }
      // ... QQ 同理
      return null;
    }, []);
    
    return AuthShell(
      title: l10n.authWelcomeBack,
      subtitle: l10n.authLoginSubtitle,
      logo: const AuthBrandLogo(),
      leading: const AppBackButton(fallbackRoute: AppRoutes.home),
      centerTitle: true,
      formModeSelector: _LoginModeTabs(mode: state.mode, onChanged: notifier.updateMode),
      form: Form(
        key: formKey,
        child: Column(
          children: [
            // 邮箱字段
            AuthEmailField(controller: emailController),
            // 密码/验证码字段（根据 mode 切换）
            if (state.mode == AuthLoginMode.password)
              AuthPasswordField(controller: passwordController)
            else
              AuthVerificationCodeField(
                controller: codeController,
                cooldownSeconds: state.cooldownSeconds,
                isSendingCode: state.isSendingCode,
                onSendCode: () => notifier.sendCode(scene: AuthVerificationScene.login),
              ),
            // 错误提示
            if (state.errorMessage != null)
              AuthErrorToast(message: state.errorMessage!),
            // 登录按钮
            AuthSubmitButton(
              isLoading: state.isSubmitting,
              label: l10n.authSignIn,
              onPress: () async {
                if (!formKey.currentState!.validate()) return;
                notifier.updateEmail(emailController.text);
                notifier.updatePassword(passwordController.text);
                notifier.updateCode(codeController.text);
                final session = await notifier.submit();
                if (session != null && context.mounted) {
                  AuthNavigator.goAfterLogin(context, returnTo: returnTo);
                }
              },
            ),
            // 导航链接
            AuthNavLinks(
              onRegister: () => context.push(AppRoutes.register),
              onForgotPassword: () => context.push(AppRoutes.forgotPassword),
            ),
            // OAuth 按钮组（独立组件）
            OAuthButtonsSection(
              providers: ref.watch(availableOAuthProvidersProvider),
              onWechatComplete: (code, state) => notifier.completeOAuthCallback(
                provider: OAuthProviderType.wechat, code: code, state: state,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**新文件**: `lib/features/auth/presentation/widgets/auth/oauth_buttons_section.dart`

```dart
/// 所有可用 OAuth 登录方式的按钮组。
///
/// 从 [availableOAuthProvidersProvider] 获取当前平台支持的 provider 列表，
/// 每个按钮点击后委托给对应的 [OAuthProvider] service。
class OAuthButtonsSection extends ConsumerWidget {
  // ...
}
```

---

### 2.4 预期效果

| 文件 | 重构前 | 重构后 | 变化 |
|------|--------|--------|------|
| `login_page.dart` | 656 | ~150 | **-77%** |
| `login_form_provider.dart` | 366 | ~120 | **-67%** |
| `register_form_provider.dart` | 194 | ~60 | **-69%** |
| `password_reset_provider.dart` | 184 | ~50 | **-73%** |
| `account_provider.dart` | 273 | ~150 | **-45%** |
| `remote_data_source.dart` | 357 | ~280 | **-22%** |
| **新增** service 层 | 0 | ~350 | — |
| **新增** 共享 widget | 0 | ~120 | — |
| **总计** | ~2030 | ~1280 | **-37%** |

### 2.5 不做的事情

| 不做 | 原因 |
|------|------|
| 引入 `flutter_appauth` | 微信/QQ OAuth 非标准 OIDC，不兼容 |
| 引入 `flutter_form_builder` | Forui `FTextFormField` 已满足需求，问题不在表单组件层 |
| 引入 `bloc`/`cubit` | Riverpod 已足够，问题在于代码组织而非状态管理框架 |
| 拆分 `AuthRemoteDataSource` 为多个 datasource | 357 行并不大，提取 `_persistSession` 后约 280 行，一个 datasource 管理所有认证 API 是合理的 |
| 改变 `AuthSessionNotifier` | 120 行，结构清晰，无需改动 |

### 2.6 实施顺序与风险

| 步骤 | 预计工时 | 风险 | 可独立交付 |
|------|----------|------|------------|
| Step 1: AuthActionRunner | 0.5h | 极低 — 纯提取 | ✅ |
| Step 2: BaseAuthFormNotifier | 1.5h | 低 — 子类结构清晰 | ✅ |
| Step 3: OAuthProvider 策略 | 2h | 中 — 涉及微信桌面服务器生命周期 | ✅ |
| Step 4: OAuthCallbackParser | 0.5h | 极低 — 纯提取 | ✅ |
| Step 5: _persistSession | 0.5h | 极低 — 纯提取 | ✅ |
| Step 6: 分解 LoginPage | 2h | 中 — UI 变更需要验证 | ✅ |
| **总计** | **7h** | | |

建议按 Step 1 → 5 → 2 → 4 → 3 → 6 的顺序实施（先做低风险的提取，再做中风险的策略模式，最后做 UI 分解）。

---

## 三、方案对比

| 维度 | 当前架构 | 本方案 |
|------|----------|--------|
| 新增登录方式 | 改 State 加字段 + 加 Notifier 方法 + 改 UI 加 Panel | 实现 `OAuthProvider` 接口 + 注册到 provider 列表 |
| 表单验证逻辑 | 3 处各写一遍 | 基类统一 |
| 错误处理 | 每个方法各写 try/catch | `AuthActionRunner` 统一 |
| OAuth 平台选择 | UI 层 40 行 if/else | service 层自动 fallback |
| LoginPage 行数 | 656 | ~150 |
| 测试难度 | 需 pumpWidget 整个页面 | service 层可独立单测 |

---

*方案日期: 2026-07-10*
