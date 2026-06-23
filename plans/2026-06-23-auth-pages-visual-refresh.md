# Auth Pages Visual Refresh — Design Spec

- **Date**: 2026-06-23
- **Scope**: Luminous (`Luminous/`) — 登录、注册、忘记密码三个 auth 页面的视觉优化
- **Status**: Approved (方案 A · 温暖品牌型)
- **Owner**: frontend (Luminous)

## 背景与目标

当前登录/注册页视觉过于素净:只有居中文字标题 + 表单字段,缺少品牌识别度与温度感。用户反馈"感觉少了点东西"。

本次优化在保留现有渐变背景、白色卡片、阴影、动画的基础上,补充三个方向的视觉元素,提升品牌感与亲和力,同时不破坏现有交互逻辑与响应式布局。

## 确认决策

- **方案基调**: A · 温暖品牌型 — Logo 突出 + 大标题欢迎语 + 字段图标,亲切陪伴感
- **服务条款/隐私政策链接**: 先用 toast 占位(无真实协议页),不实际跳转
- **副标题文案**: 采用设计稿拟定的文案(详见 l10n 一节)
- **忘记密码页**: 与登录、注册一起改,保持三页视觉统一

## 设计原则

1. **改动集中在共享 widget** — `AuthShell` 和 `AuthTextField`,页面层只调传参
2. **纯视觉,不动逻辑** — data/provider 层零改动,不影响 WeChat OAuth、表单校验、路由
3. **沿用现有设计 token** — 颜色、间距、圆角、阴影全部复用 `app_design.dart` 的 token,不引入新常量
4. **保持暗色模式与多主题兼容** — Logo 容器、图标颜色用 `AppThemeSurface` 语义色,不写死 hex
5. **Material Icons 而非 emoji** — 字段图标用 `Icons`(如 `Icons.mail_outline`、`Icons.lock_outline`),保证跨平台一致性

## 改动清单

### 1. `AuthShell` 扩展(核心)

**文件**: `Luminous/lib/features/auth/presentation/widgets/auth_shell.dart`

`AuthShell` 新增两个可选槽:

- `final Widget? logo;` — 显示在标题上方的 Logo 组件
- `final String? subtitle;` — 显示在标题下方的副标题文案

`_AuthPageHeader` 重构为三段式纵向布局(仅当 `logo` 或 `subtitle` 非空时启用;为保持向后兼容,两者皆空时维持原有横向 Row 布局):

```
[Logo (64x64, 圆角容器)]
[Title (居中, displaySm)]
[Subtitle (居中, bodySm, mute 色)]
```

**Logo 组件封装**: 新增 `AuthBrandLogo` 公开 widget(页面层需直接构造):
- 64x64 外层容器,圆角 `AppRadiusTokens.xl`(16),背景用浅灰渐变 `canvasSoft → canvasSoft2` 解决白色 app icon 与白色卡片背景的边界融合问题
- 内部 12px padding + 圆角包裹 `Image.asset('assets/icons/luminous_app_icon.png')`
- 微阴影 `AppShadowTokens.level1` 增加层次
- 图标尺寸响应式: 移动端 64px,桌面端可略大(沿用 `AppLayoutTokens.resolve`)

### 2. `AuthTextField` 加 `prefix` 槽

**文件**: 同上 `auth_shell.dart`

`AuthTextField` 已有 `suffix` 槽,补一个对称的:

- `final Widget? prefix;`

布局从 `[TextField] [suffix]` 变为 `[prefix] [TextField] [suffix]`,prefix 与 suffix 用相同的 `AppSpacingTokens.xs` 间距。字段图标尺寸 20-22px,颜色用 `surface.mute`(未聚焦)/ `theme.colorScheme.primary`(聚焦时)。

图标与字段语义的对应:

| 字段 | prefix icon |
|---|---|
| 邮箱 | `Icons.mail_outline` |
| 密码/新密码/确认密码 | `Icons.lock_outline` |
| 验证码 | `Icons.shield_outlined`(盾牌语义,契合安全码) |
| 昵称 | `Icons.person_outline` |
| WeChat 回调链接 | `Icons.link`(URL 语义) |

### 3. 密码可见切换

**文件**: 同上 `auth_shell.dart`

`AuthTextField` 已是 `StatefulWidget`(`_AuthTextFieldState`)。在 `build` 中,当 `widget.obscureText == true` 且未传自定义 `suffix` 时,自动注入一个密码可见性切换 IconButton 作为 suffix:

```dart
suffix ??= IconButton(
  icon: Icon(_obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
  onPressed: () => setState(() => _obscured = !_obscured),
  visualDensity: VisualDensity.compact,
  iconSize: 20,
);
```

新增 `bool _obscured = widget.obscureText;` 状态字段。`TextField.obscureText` 改用 `_obscured`。`didUpdateWidget` 中同步:当外部 `obscureText` 变化时重置 `_obscured`。

**注意**: 页面层调用密码字段时**不再**手动传 suffix,由 widget 自治。

### 4. 注册页服务条款

**文件**: `Luminous/lib/features/auth/presentation/pages/register_page.dart`

在主按钮(`AuthPrimaryButton`)与底部 `AuthFooterAction` 之间插入一行协议同意提示:

```
创建即表示同意《服务条款》与《隐私政策》
```

- 文案用新 l10n key `authTermsAgreement`(详见 l10n 一节)
- 《服务条款》《隐私政策》用 `link` 色,点击触发 `AppToast.show` 占位提示("Terms coming soon")
- 新增 `AuthTermsNotice` 小 widget(放在 `auth_shell.dart` 与其他 auth 共享 widget 并列),接收两个回调 `onTerms` / `onPrivacy`,便于未来替换为真实跳转

### 5. 欢迎文案与 l10n

**新增 ARB key**(en + zh 都补):

| key | en | zh |
|---|---|---|
| `authLoginSubtitle` | "Sign in to continue your health tracking" | "登录以继续你的健康记录" |
| `authRegisterSubtitle` | "Join Luminous and start your health journal" | "加入 Luminous,开启你的健康记录" |
| `authForgotPasswordSubtitle` | "We'll send a code to reset your password" | "我们将发送验证码以重置你的密码" |
| `authTermsAgreement` | "By creating an account, you agree to the {terms} and {privacy}" | "创建即表示同意{terms}与{privacy}" |
| `authTermsOfService` | "Terms of Service" | "服务条款" |
| `authPrivacyPolicy` | "Privacy Policy" | "隐私政策" |
| `authTermsComingSoonToast` | "Terms and privacy policy will be available soon." | "服务条款与隐私政策即将上线。" |

**复用已存在的 key**:
- 登录标题继续用 `authSignIn`("Sign in" / "登录")? **改为** `authWelcomeBack`("Welcome back" / "欢迎回来")作为主标题,更贴合方案 A 的亲切基调
- 注册标题继续用 `authCreateAccountAction`
- 忘记密码标题继续用 `authResetPasswordAction`

> `authWelcomeBack` 已存在于 en/zh ARB 与生成的 localizations 类中,此前未被使用,本次正式启用。

### 6. 三页接入

**`login_page.dart`**:
- `AuthShell(...)` 传入 `logo: const AuthBrandLogo()`, `subtitle: l10n?.authLoginSubtitle`, `title: l10n?.authWelcomeBack ?? 'Welcome back'`
- 邮箱字段加 `prefix: Icon(Icons.mail_outline)`
- 密码字段 prefix 加 `Icon(Icons.lock_outline)`(suffix 自动注入可见切换,不再手动传)
- WeChat 回调输入字段加 `prefix: Icon(Icons.link)`

**`register_page.dart`**:
- `AuthShell(...)` 传入 logo + `authRegisterSubtitle` + `authCreateAccountAction`
- 邮箱 prefix `Icons.mail_outline`
- 密码 prefix `Icons.lock_outline`(suffix 自动)
- 昵称 prefix `Icons.person_outline`
- 主按钮后插入 `AuthTermsNotice`

**`forgot_password_page.dart`**:
- `AuthShell(...)` 传入 logo + `authForgotPasswordSubtitle` + `authResetPasswordAction`
- 邮箱 prefix `Icons.mail_outline`
- 新密码/确认密码 prefix `Icons.lock_outline`(suffix 自动可见切换)

## 不在范围内

- ❌ 不改 data/provider 层(WeChat OAuth、表单状态机、API 调用)
- ❌ 不改路由、转场动画
- ❌ 不新增第三方社交登录(Apple/Google)
- ❌ 不做注册成功后的 onboarding 流程
- ❌ 不做 inline 字段级校验错误(本次仍用 toast)
- ❌ 不真实落地服务条款/隐私政策页面(toast 占位)

## 验证

- `flutter analyze` 无新增 warning
- `flutter test` 既有测试全通过(auth 相关 widget 测试若有 snapshot 需更新)
- 人工检查:登录/注册/忘记密码三页在浅色、暗色、三种调色板(classic/bluePink/yellowGreen)下 Logo、图标、文案显示正常
- 人工检查:桌面端与移动端断点下布局不破
- WeChat OAuth、密码切换、验证码发送等交互功能回归正常

## 文档

完成后按 `Luminous/docs/README.md` 要求,追加 `Luminous/docs/migration-log/2026-06-23.md` 记录本次视觉改动与新增 l10n key。
