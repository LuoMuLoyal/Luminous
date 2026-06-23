# Auth Pages Visual Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为登录、注册、忘记密码三个 auth 页面增加品牌 Logo、欢迎副标题、字段图标和密码可见切换,提升视觉品牌感与亲和力。

**Architecture:** 改动集中在共享 widget `auth_shell.dart`(扩展 `AuthShell` 加 logo/subtitle 槽、`AuthTextField` 加 prefix 槽并自治密码可见切换、新增 `AuthBrandLogo` 和 `AuthTermsNotice`)。三个页面层只调传参,l10n 补 7 个新 key。纯视觉,不动 data/provider/OAuth 逻辑。

**Tech Stack:** Flutter,Dart,Riverpod,go_router,flutter_animate,Material Icons,ARB 本地化。

**Spec:** `Luminous/plans/2026-06-23-auth-pages-visual-refresh.md`

**Repo:** 在 `Luminous/` 子仓库内工作,用 `git -C Luminous ...` 提交。

---

## 文件结构

| 文件 | 责任 | 操作 |
|---|---|---|
| `Luminous/lib/features/auth/presentation/widgets/auth_shell.dart` | 共享 auth widget: AuthShell、AuthTextField、新增 AuthBrandLogo、AuthTermsNotice | 修改 |
| `Luminous/lib/l10n/app_en.arb` | 英文文案 | 修改 |
| `Luminous/lib/l10n/app_zh.arb` | 中文文案 | 修改 |
| `Luminous/lib/l10n/app_localizations.dart` | 重新生成(运行 `flutter gen-l10n`) | 重新生成 |
| `Luminous/lib/l10n/app_localizations_en.dart` | 重新生成 | 重新生成 |
| `Luminous/lib/l10n/app_localizations_zh.dart` | 重新生成 | 重新生成 |
| `Luminous/lib/features/auth/presentation/pages/login_page.dart` | 登录页接入 logo/subtitle/prefix | 修改 |
| `Luminous/lib/features/auth/presentation/pages/register_page.dart` | 注册页接入 + 服务条款 | 修改 |
| `Luminous/lib/features/auth/presentation/pages/forgot_password_page.dart` | 忘记密码页接入 | 修改 |
| `Luminous/test/auth/auth_widgets_test.dart` | widget 测试 | 修改(加新测试) |
| `Luminous/docs/migration-log/2026-06-23.md` | 迁移日志 | 新建 |

---

## Task 1: 新增 l10n 文案(基础)

**Files:**
- Modify: `Luminous/lib/l10n/app_en.arb`
- Modify: `Luminous/lib/l10n/app_zh.arb`

- [ ] **Step 1: 在 `app_en.arb` 中追加新 key**

打开 `Luminous/lib/l10n/app_en.arb`,定位到 `"authResetPasswordSuccess": "Password updated. Please sign in again.",` 这一行(约 953 行),在其**后面**插入以下条目:

```json
  "authLoginSubtitle": "Sign in to continue your health tracking",
  "authRegisterSubtitle": "Join Luminous and start your health journal",
  "authForgotPasswordSubtitle": "We'll send a code to reset your password",
  "authTermsAgreement": "By creating an account, you agree to the {terms} and {privacy}",
  "@authTermsAgreement": {
    "placeholders": {
      "terms": {
        "type": "String"
      },
      "privacy": {
        "type": "String"
      }
    }
  },
  "authTermsOfService": "Terms of Service",
  "authPrivacyPolicy": "Privacy Policy",
  "authTermsComingSoonToast": "Terms and privacy policy will be available soon.",
```

- [ ] **Step 2: 在 `app_zh.arb` 中追加对应中文**

打开 `Luminous/lib/l10n/app_zh.arb`,定位到同名的 `"authResetPasswordSuccess"` 行(约 953 行,中文为"密码已更新..."),在其**后面**插入:

```json
  "authLoginSubtitle": "登录以继续你的健康记录",
  "authRegisterSubtitle": "加入 Luminous,开启你的健康记录",
  "authForgotPasswordSubtitle": "我们将发送验证码以重置你的密码",
  "authTermsAgreement": "创建即表示同意{terms}与{privacy}",
  "authTermsOfService": "服务条款",
  "authPrivacyPolicy": "隐私政策",
  "authTermsComingSoonToast": "服务条款与隐私政策即将上线。",
```

> 注意:`@authTermsAgreement` 的 placeholders 定义只在 `app_en.arb`(模板)中需要,`app_zh.arb` 不重复声明。

- [ ] **Step 3: 重新生成本地化代码**

在 `Luminous/` 目录运行:

```bash
cd Luminous && flutter gen-l10n
```

预期:无报错,`lib/l10n/app_localizations.dart`、`app_localizations_en.dart`、`app_localizations_zh.dart` 自动更新,新增 `authLoginSubtitle` / `authRegisterSubtitle` / `authForgotPasswordSubtitle` / `authTermsAgreement(String terms, String privacy)` / `authTermsOfService` / `authPrivacyPolicy` / `authTermsComingSoonToast` 这些 getter。

- [ ] **Step 4: 验证生成结果**

运行(在 `Luminous/` 目录):

```bash
flutter analyze lib/l10n
```

预期:无新增 warning/error。如果看到生成的文件有问题,检查 ARB 是否漏了逗号或引号。

- [ ] **Step 5: 提交**

```bash
cd Luminous && git add lib/l10n/ && git commit -m "feat(auth): 新增 auth 视觉改动的 l10n 文案"
```

---

## Task 2: 扩展 AuthShell 支持 logo 与 subtitle

**Files:**
- Modify: `Luminous/lib/features/auth/presentation/widgets/auth_shell.dart:9-117`
- Test: `Luminous/test/auth/auth_widgets_test.dart`(在 Task 6 统一加测试)

- [ ] **Step 1: 给 AuthShell 加 logo 和 subtitle 槽**

在 `auth_shell.dart` 中找到 `AuthShell` 类(约第 9 行),修改其字段与构造函数。

**原代码(约 9-17 行):**

```dart
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.form,
    this.enableFormAnimation = true,
    this.leading,
    this.centerTitle = false,
  });

  final String title;
  final Widget form;
  final bool enableFormAnimation;
  final Widget? leading;
  final bool centerTitle;
```

**改为:**

```dart
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.form,
    this.enableFormAnimation = true,
    this.leading,
    this.centerTitle = false,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget form;
  final bool enableFormAnimation;
  final Widget? leading;
  final bool centerTitle;
  final Widget? logo;
  final String? subtitle;
```

- [ ] **Step 2: 把 logo/subtitle 传给 _AuthPageHeader**

在同一文件找到 `AuthShell.build` 里构造 `_AuthPageHeader` 的地方(约第 60-65 行):

**原代码:**

```dart
                    _AuthPageHeader(
                      title: title,
                      leading: leading,
                      centerTitle: centerTitle,
                      typography: typography,
                    ),
```

**改为:**

```dart
                    _AuthPageHeader(
                      title: title,
                      leading: leading,
                      centerTitle: centerTitle,
                      typography: typography,
                      logo: logo,
                      subtitle: subtitle,
                    ),
```

- [ ] **Step 3: 重构 _AuthPageHeader 支持三段式布局**

在同一文件找到 `_AuthPageHeader` 类(约第 83-117 行),整体替换为:

```dart
class _AuthPageHeader extends StatelessWidget {
  const _AuthPageHeader({
    required this.title,
    required this.leading,
    required this.centerTitle,
    required this.typography,
    this.logo,
    this.subtitle,
  });

  final String title;
  final Widget? leading;
  final bool centerTitle;
  final AppTypographyScale typography;
  final Widget? logo;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    // 当没有 logo 也没有 subtitle 时,保持原有横向行布局(向后兼容)。
    if (logo == null && subtitle == null) {
      return Row(
        children: [
          SizedBox(
            width: 48,
            child: leading == null
                ? null
                : Align(alignment: Alignment.centerLeft, child: leading),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: centerTitle ? TextAlign.center : TextAlign.left,
              style: typography.displaySm,
            ),
          ),
          const SizedBox(width: 48),
        ],
      );
    }

    // 三段式纵向布局: Logo + Title + Subtitle(支持可选 leading)。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leading != null)
          Align(alignment: Alignment.centerLeft, child: leading),
        if (logo != null) ...[
          Center(child: logo),
          const SizedBox(height: AppSpacingTokens.md),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: typography.displaySm,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacingTokens.xs),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: typography.bodySm.copyWith(
              color: Theme.of(context).extension<AppThemeSurface>()!.mute,
            ),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 4: 验证编译**

在 `Luminous/` 目录:

```bash
flutter analyze lib/features/auth/presentation/widgets/auth_shell.dart
```

预期:无 error。可能会有 "unused field" 之类的提示(因为 logo/subtitle 还没被页面用),但不影响编译。

- [ ] **Step 5: 提交**

```bash
cd Luminous && git add lib/features/auth/presentation/widgets/auth_shell.dart && git commit -m "feat(auth): AuthShell 支持 logo 与 subtitle 三段式标题区"
```

---

## Task 3: 新增 AuthBrandLogo widget

**Files:**
- Modify: `Luminous/lib/features/auth/presentation/widgets/auth_shell.dart`(追加在文件末尾)

- [ ] **Step 1: 在 auth_shell.dart 末尾追加 AuthBrandLogo**

在 `auth_shell.dart` 文件**最末尾**(`AuthPrimaryButton` 类之后)追加:

```dart
/// Auth 页面品牌 Logo。用浅灰圆角渐变容器包裹白色 app icon,
/// 解决白底图标与白色卡片背景融合的问题,并增加层次感。
class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({super.key, this.size = 64});

  final double size;

  static const String _assetPath = 'assets/icons/luminous_app_icon.png';

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[surface.canvasSoft, surface.canvasSoft2],
        ),
        boxShadow: AppShadowTokens.level1,
      ),
      padding: const EdgeInsets.all(AppSpacingTokens.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Image.asset(
          _assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const SizedBox.shrink(),
        ),
      ),
    );
  }
}
```

> 说明:用 `surface.canvasSoft` / `canvasSoft2` 渐变,保证在 light/dark/三调色板下都协调。`errorBuilder` 防止资源缺失崩溃。圆角用 token 不写死。`size` 默认 64,留可配置余地。

- [ ] **Step 2: 验证编译**

```bash
cd Luminous && flutter analyze lib/features/auth/presentation/widgets/auth_shell.dart
```

预期:无 error。

- [ ] **Step 3: 提交**

```bash
cd Luminous && git add lib/features/auth/presentation/widgets/auth_shell.dart && git commit -m "feat(auth): 新增 AuthBrandLogo 品牌标识 widget"
```

---

## Task 4: AuthTextField 加 prefix 槽 + 密码可见切换

**Files:**
- Modify: `Luminous/lib/features/auth/presentation/widgets/auth_shell.dart:185-279`

这是本计划最复杂的改动。分两步:先加 prefix 槽,再加密码可见切换。

- [ ] **Step 1: AuthTextField 加 prefix 字段**

找到 `AuthTextField` 类(约第 185 行),修改字段与构造函数。

**原代码(约 185-207 行):**

```dart
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final bool enabled;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}
```

**改为:**

```dart
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}
```

- [ ] **Step 2: _AuthTextFieldState 加密码可见状态**

找到 `_AuthTextFieldState` 类(约第 209 行)。在 `_focusNode` 字段之后加 `_obscured` 状态,并在 `initState` 初始化、`didUpdateWidget` 同步。

**原代码(约 209-228 行):**

```dart
class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    setState(() {});
  }
```

**改为:**

```dart
class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focusNode;
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
    _obscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  void _toggleObscure() {
    setState(() => _obscured = !_obscured);
  }
```

- [ ] **Step 3: build 方法接入 prefix 与密码可见切换**

找到 `_AuthTextFieldState.build`(约第 230-279 行)。完整替换。

**原代码(约 230-279 行):**

```dart
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final borderColor = _focusNode.hasFocus
        ? theme.colorScheme.primary
        : surface.hairline;
    final contentColor = widget.enabled
        ? theme.colorScheme.onSurface
        : surface.mute;

    return _AuthControlFrame(
      backgroundColor: widget.enabled ? surface.canvas : surface.canvasSoft,
      borderColor: borderColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                label: widget.label,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  maxLines: 1,
                  style: typography.bodyMd.copyWith(color: contentColor),
                  cursorColor: theme.colorScheme.primary,
                  decoration: InputDecoration.collapsed(
                    hintText: widget.label,
                    hintStyle: typography.bodySm.copyWith(color: surface.mute),
                  ),
                ),
              ),
            ),
            if (widget.suffix != null) ...[
              const SizedBox(width: AppSpacingTokens.xs),
              widget.suffix!,
            ],
          ],
        ),
      ),
    );
  }
```

**改为:**

```dart
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final borderColor = _focusNode.hasFocus
        ? theme.colorScheme.primary
        : surface.hairline;
    final contentColor = widget.enabled
        ? theme.colorScheme.onSurface
        : surface.mute;
    final iconColor =
        _focusNode.hasFocus ? theme.colorScheme.primary : surface.mute;

    // 密码字段: 若外部未自定义 suffix,自动注入可见性切换按钮。
    final Widget? effectiveSuffix = widget.suffix ??
        (widget.obscureText
            ? IconButton(
                onPressed: _toggleObscure,
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                color: iconColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                tooltip: _obscured ? 'Show password' : 'Hide password',
              )
            : null);

    return _AuthControlFrame(
      backgroundColor: widget.enabled ? surface.canvas : surface.canvasSoft,
      borderColor: borderColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
        child: Row(
          children: [
            if (widget.prefix != null) ...[
              IconTheme.merge(
                data: IconThemeData(color: iconColor, size: 20),
                child: widget.prefix!,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
            ],
            Expanded(
              child: Semantics(
                label: widget.label,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  obscureText: _obscured,
                  maxLines: 1,
                  style: typography.bodyMd.copyWith(color: contentColor),
                  cursorColor: theme.colorScheme.primary,
                  decoration: InputDecoration.collapsed(
                    hintText: widget.label,
                    hintStyle: typography.bodySm.copyWith(color: surface.mute),
                  ),
                ),
              ),
            ),
            if (effectiveSuffix != null) ...[
              const SizedBox(width: AppSpacingTokens.xs),
              effectiveSuffix,
            ],
          ],
        ),
      ),
    );
  }
```

> 关键点:`obscureText: _obscured`(不再是 `widget.obscureText`)。prefix 用 `IconTheme.merge` 包裹,让图标自动继承颜色与尺寸。密码切换仅当 `widget.obscureText == true`(即这是个密码字段)且未自定义 suffix 时启用。

- [ ] **Step 4: 验证编译**

```bash
cd Luminous && flutter analyze lib/features/auth/presentation/widgets/auth_shell.dart
```

预期:无 error。

- [ ] **Step 5: 提交**

```bash
cd Luminous && git add lib/features/auth/presentation/widgets/auth_shell.dart && git commit -m "feat(auth): AuthTextField 支持 prefix 图标与密码可见切换"
```

---

## Task 5: 新增 AuthTermsNotice widget

**Files:**
- Modify: `Luminous/lib/features/auth/presentation/widgets/auth_shell.dart`(追加)

- [ ] **Step 1: 在 auth_shell.dart 追加 AuthTermsNotice**

在 `AuthBrandLogo` 类**之后**(即文件末尾)追加:

```dart
/// 注册页底部服务条款提示。当前用 toast 占位,未来可替换为真实跳转。
class AuthTermsNotice extends StatelessWidget {
  const AuthTermsNotice({
    super.key,
    required this.onTerms,
    required this.onPrivacy,
  });

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(Theme.of(context).colorScheme.onSurface)
        : AppTypographyTokens.desktop(Theme.of(context).colorScheme.onSurface);
    final l10n = AppLocalizations.of(context);

    final baseStyle = typography.bodySm.copyWith(color: surface.body);
    final linkStyle = typography.bodySm.copyWith(
      color: surface.link,
      fontWeight: FontWeight.w600,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: l10n?.authTermsAgreement(
                      l10n.authTermsOfService,
                      l10n.authPrivacyPolicy,
                    ) ??
                    'By creating an account, you agree to the Terms of Service and Privacy Policy',
                // 注意: 上面的占位串只在 l10n 为 null 时使用,不带链接。
                style: baseStyle,
                children: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

> **修正**:上面用 `TextSpan` + 占位串的方式无法实现部分文字可点击。改用 `Wrap` + `TextButton` 的方式更稳妥,见 Step 2。

- [ ] **Step 2: 用 Wrap+TextButton 重写 AuthTermsNotice(替换 Step 1 代码)**

把 Step 1 写入的 `AuthTermsNotice` 整体替换为:

```dart
/// 注册页底部服务条款提示。当前用 toast 占位,未来可替换为真实跳转。
class AuthTermsNotice extends StatelessWidget {
  const AuthTermsNotice({
    super.key,
    required this.onTerms,
    required this.onPrivacy,
  });

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final l10n = AppLocalizations.of(context);

    final linkStyle = typography.bodySm.copyWith(
      color: surface.link,
      fontWeight: FontWeight.w600,
    );
    const linkButtonStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsets.zero),
      minimumSize: WidgetStatePropertyAll(Size(0, 28)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    // l10n.authTermsAgreement 带占位符,需拆成 段头 + terms + 分隔 + privacy。
    // en: "By creating an account, you agree to the {terms} and {privacy}"
    // zh: "创建即表示同意{terms}与{privacy}"
    // 直接用拼接更可控,避免占位符渲染问题。
    final String leadText =
        l10n?.authTermsAgreement('', '') ?? 'By creating an account, you agree to the ';
    final String connector =
        l10n?.localeName.startsWith('zh') == true ? '与' : ' and ';
    final String termsLabel = l10n?.authTermsOfService ?? 'Terms of Service';
    final String privacyLabel = l10n?.authPrivacyPolicy ?? 'Privacy Policy';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xs),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            Text(leadText, style: typography.bodySm.copyWith(color: surface.body)),
            TextButton(
              onPressed: onTerms,
              style: linkButtonStyle,
              child: Text(termsLabel, style: linkStyle),
            ),
            Text(connector, style: typography.bodySm.copyWith(color: surface.body)),
            TextButton(
              onPressed: onPrivacy,
              style: linkButtonStyle,
              child: Text(privacyLabel, style: linkStyle),
            ),
          ],
        ),
      ),
    );
  }
}
```

> 说明:不用 `authTermsAgreement(terms, privacy)` 的占位符渲染(它在不同语言下 `{terms}`/`{privacy}` 位置不定,拼接难控制),而是取 `authTermsAgreement('', '')` 的前缀 + 手动拼接 terms 链接 + connector(`与`/` and `)+ privacy 链接。leadText 在英文会是 "By creating an account, you agree to the ",中文会是 "创建即表示同意",connector 跟随语言。

- [ ] **Step 3: 加 AppLocalizations import(若缺)**

检查 `auth_shell.dart` 顶部 import 区是否已有 `import 'package:luminous/l10n/app_localizations.dart';`。Task 5 用到了 `AppLocalizations.of(context)`,若没有则补上。在第 5 行 `import 'package:luminous/core/theme/app_theme_extensions.dart';` **后面**加一行:

```dart
import 'package:luminous/l10n/app_localizations.dart';
```

> `AppLocalizations.of(context)` 返回 nullable,所以上面用了 `l10n?.authTermsAgreement(...)` 与 `??` 兜底。

- [ ] **Step 4: 验证编译**

```bash
cd Luminous && flutter analyze lib/features/auth/presentation/widgets/auth_shell.dart
```

预期:无 error。

- [ ] **Step 5: 提交**

```bash
cd Luminous && git add lib/features/auth/presentation/widgets/auth_shell.dart && git commit -m "feat(auth): 新增 AuthTermsNotice 服务条款提示 widget"
```

---

## Task 6: 接入登录页

**Files:**
- Modify: `Luminous/lib/features/auth/presentation/pages/login_page.dart`

- [ ] **Step 1: 修改 AuthShell 调用,传 logo + subtitle + 新标题**

在 `login_page.dart` 找到 `return AuthShell(` 这一段(约第 69-72 行)。

**原代码:**

```dart
    return AuthShell(
      title: l10n?.authSignIn ?? 'Sign in',
      centerTitle: true,
      form: Column(
```

**改为:**

```dart
    return AuthShell(
      title: l10n?.authWelcomeBack ?? 'Welcome back',
      subtitle: l10n?.authLoginSubtitle,
      logo: const AuthBrandLogo(),
      centerTitle: true,
      form: Column(
```

- [ ] **Step 2: 邮箱字段加 prefix 图标**

找到邮箱 `AuthTextField`(约第 108-114 行)。

**原代码:**

```dart
          AuthTextField(
            key: const Key('auth-login-email-field'),
            controller: _emailController,
            label: l10n?.authEmailLabel ?? 'Email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
```

**改为:**

```dart
          AuthTextField(
            key: const Key('auth-login-email-field'),
            controller: _emailController,
            label: l10n?.authEmailLabel ?? 'Email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            prefix: const Icon(Icons.mail_outline),
          ),
```

- [ ] **Step 3: 密码字段加 prefix 图标(移除手动 suffix 风险)**

找到密码模式下的 `AuthTextField`(约第 131-139 行,在 `AnimatedSwitcher` 内)。

**原代码:**

```dart
                ? AuthTextField(
                    key: const ValueKey('password-login-field'),
                    controller: _passwordController,
                    label: l10n?.authPasswordLabel ?? 'Password',
                    hint:
                        l10n?.authPasswordHint ??
                        'At least 8 characters, ideally with mixed case and numbers',
                    obscureText: true,
                  )
```

**改为:**

```dart
                ? AuthTextField(
                    key: const ValueKey('password-login-field'),
                    controller: _passwordController,
                    label: l10n?.authPasswordLabel ?? 'Password',
                    hint:
                        l10n?.authPasswordHint ??
                        'At least 8 characters, ideally with mixed case and numbers',
                    obscureText: true,
                    prefix: const Icon(Icons.lock_outline),
                  )
```

> 不需要传 suffix,密码可见切换已由 AuthTextField 自治(Task 4)。

- [ ] **Step 4: WeChat 回调输入字段加 prefix 图标**

找到 `_WechatOAuthPanel` 里的 `AuthTextField`(约第 444-453 行,key 为 `wechat-callback-input`)。

**原代码:**

```dart
          AuthTextField(
            key: const Key('wechat-callback-input'),
            controller: callbackController,
            label:
                l10n?.authWechatCallbackLabel ?? 'WeChat callback link / code',
            hint:
                l10n?.authWechatCallbackHint ??
                'Paste the callback URL after scanning',
            keyboardType: TextInputType.url,
          ),
```

**改为:**

```dart
          AuthTextField(
            key: const Key('wechat-callback-input'),
            controller: callbackController,
            label:
                l10n?.authWechatCallbackLabel ?? 'WeChat callback link / code',
            hint:
                l10n?.authWechatCallbackHint ??
                'Paste the callback URL after scanning',
            keyboardType: TextInputType.url,
            prefix: const Icon(Icons.link),
          ),
```

- [ ] **Step 5: 验证编译**

```bash
cd Luminous && flutter analyze lib/features/auth/presentation/pages/login_page.dart
```

预期:无 error。

- [ ] **Step 6: 提交**

```bash
cd Luminous && git add lib/features/auth/presentation/pages/login_page.dart && git commit -m "feat(auth): 登录页接入 logo/副标题/字段图标"
```

---

## Task 7: 接入注册页 + 服务条款

**Files:**
- Modify: `Luminous/lib/features/auth/presentation/pages/register_page.dart`

- [ ] **Step 1: 修改 AuthShell 调用**

在 `register_page.dart` 找到 `return AuthShell(`(约第 47-49 行)。

**原代码:**

```dart
    return AuthShell(
      title: l10n?.authCreateAccountAction ?? 'Create account',
      centerTitle: true,
      form: Column(
```

**改为:**

```dart
    return AuthShell(
      title: l10n?.authCreateAccountAction ?? 'Create account',
      subtitle: l10n?.authRegisterSubtitle,
      logo: const AuthBrandLogo(),
      centerTitle: true,
      form: Column(
```

- [ ] **Step 2: 邮箱字段加 prefix**

找到邮箱 `AuthTextField`(约第 54-59 行)。

**原代码:**

```dart
          AuthTextField(
            controller: _emailController,
            label: l10n?.authEmailLabel ?? 'Email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
```

**改为:**

```dart
          AuthTextField(
            controller: _emailController,
            label: l10n?.authEmailLabel ?? 'Email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            prefix: const Icon(Icons.mail_outline),
          ),
```

- [ ] **Step 3: 密码字段加 prefix**

找到密码 `AuthTextField`(约第 82-89 行)。

**原代码:**

```dart
          AuthTextField(
            controller: _passwordController,
            label: l10n?.authPasswordLabel ?? 'Password',
            hint:
                l10n?.authPasswordHint ??
                'At least 8 characters, ideally with mixed case and numbers',
            obscureText: true,
          ),
```

**改为:**

```dart
          AuthTextField(
            controller: _passwordController,
            label: l10n?.authPasswordLabel ?? 'Password',
            hint:
                l10n?.authPasswordHint ??
                'At least 8 characters, ideally with mixed case and numbers',
            obscureText: true,
            prefix: const Icon(Icons.lock_outline),
          ),
```

- [ ] **Step 4: 昵称字段加 prefix**

找到昵称 `AuthTextField`(约第 91-95 行)。

**原代码:**

```dart
          AuthTextField(
            controller: _nicknameController,
            label: l10n?.authNicknameLabel ?? 'Nickname',
            hint: l10n?.authNicknameHint ?? 'Optional',
          ),
```

**改为:**

```dart
          AuthTextField(
            controller: _nicknameController,
            label: l10n?.authNicknameLabel ?? 'Nickname',
            hint: l10n?.authNicknameHint ?? 'Optional',
            prefix: const Icon(Icons.person_outline),
          ),
```

- [ ] **Step 5: 在主按钮后插入 AuthTermsNotice**

找到主按钮 `AuthPrimaryButton`(约第 105-118 行)与紧跟其后的 `SizedBox` + `AuthFooterAction`(约第 119-124 行)。

**原代码:**

```dart
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            label: l10n?.authCreateAccountAction ?? 'Create account',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(_emailController.text);
              notifier.updateCode(_codeController.text);
              notifier.updatePassword(_passwordController.text);
              notifier.updateNickname(_nicknameController.text);
              if (!_validateSubmit(context, l10n)) {
                return;
              }
              await notifier.submit();
            },
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          AuthFooterAction(
```

**改为**(在按钮和 footer 之间插入 terms notice):

```dart
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            label: l10n?.authCreateAccountAction ?? 'Create account',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(_emailController.text);
              notifier.updateCode(_codeController.text);
              notifier.updatePassword(_passwordController.text);
              notifier.updateNickname(_nicknameController.text);
              if (!_validateSubmit(context, l10n)) {
                return;
              }
              await notifier.submit();
            },
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          AuthTermsNotice(
            onTerms: () => AppToast.show(
              context,
              l10n?.authTermsComingSoonToast ??
                  'Terms and privacy policy will be available soon.',
            ),
            onPrivacy: () => AppToast.show(
              context,
              l10n?.authTermsComingSoonToast ??
                  'Terms and privacy policy will be available soon.',
            ),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          AuthFooterAction(
```

- [ ] **Step 6: 验证编译**

```bash
cd Luminous && flutter analyze lib/features/auth/presentation/pages/register_page.dart
```

预期:无 error。

- [ ] **Step 7: 提交**

```bash
cd Luminous && git add lib/features/auth/presentation/pages/register_page.dart && git commit -m "feat(auth): 注册页接入 logo/副标题/字段图标/服务条款"
```

---

## Task 8: 接入忘记密码页

**Files:**
- Modify: `Luminous/lib/features/auth/presentation/pages/forgot_password_page.dart`

- [ ] **Step 1: 修改 AuthShell 调用**

在 `forgot_password_page.dart` 找到 `return AuthShell(`(约第 50-52 行)。

**原代码:**

```dart
    return AuthShell(
      title: l10n?.authResetPasswordAction ?? 'Reset password',
      centerTitle: true,
      form: Column(
```

**改为:**

```dart
    return AuthShell(
      title: l10n?.authResetPasswordAction ?? 'Reset password',
      subtitle: l10n?.authForgotPasswordSubtitle,
      logo: const AuthBrandLogo(),
      centerTitle: true,
      form: Column(
```

- [ ] **Step 2: 邮箱字段加 prefix**

找到邮箱 `AuthTextField`(约第 57-62 行)。

**原代码:**

```dart
          AuthTextField(
            controller: _emailController,
            label: l10n?.authEmailLabel ?? 'Email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
```

**改为:**

```dart
          AuthTextField(
            controller: _emailController,
            label: l10n?.authEmailLabel ?? 'Email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            prefix: const Icon(Icons.mail_outline),
          ),
```

- [ ] **Step 3: 新密码字段加 prefix**

找到新密码 `AuthTextField`(约第 85-92 行,`authNewPasswordLabel`)。

**原代码:**

```dart
          AuthTextField(
            controller: _passwordController,
            label: l10n?.authNewPasswordLabel ?? 'New password',
            hint:
                l10n?.authPasswordHint ??
                'At least 8 characters, ideally with mixed case and numbers',
            obscureText: true,
          ),
```

**改为:**

```dart
          AuthTextField(
            controller: _passwordController,
            label: l10n?.authNewPasswordLabel ?? 'New password',
            hint:
                l10n?.authPasswordHint ??
                'At least 8 characters, ideally with mixed case and numbers',
            obscureText: true,
            prefix: const Icon(Icons.lock_outline),
          ),
```

- [ ] **Step 4: 确认密码字段加 prefix**

找到确认密码 `AuthTextField`(约第 94-101 行,`authConfirmPasswordLabel`)。

**原代码:**

```dart
          AuthTextField(
            controller: _confirmPasswordController,
            label: l10n?.authConfirmPasswordLabel ?? 'Confirm password',
            hint:
                l10n?.authPasswordHint ??
                'At least 8 characters, ideally with mixed case and numbers',
            obscureText: true,
          ),
```

**改为:**

```dart
          AuthTextField(
            controller: _confirmPasswordController,
            label: l10n?.authConfirmPasswordLabel ?? 'Confirm password',
            hint:
                l10n?.authPasswordHint ??
                'At least 8 characters, ideally with mixed case and numbers',
            obscureText: true,
            prefix: const Icon(Icons.lock_outline),
          ),
```

- [ ] **Step 5: 验证编译**

```bash
cd Luminous && flutter analyze lib/features/auth/presentation/pages/forgot_password_page.dart
```

预期:无 error。

- [ ] **Step 6: 提交**

```bash
cd Luminous && git add lib/features/auth/presentation/pages/forgot_password_page.dart && git commit -m "feat(auth): 忘记密码页接入 logo/副标题/字段图标"
```

---

## Task 9: 补充 widget 测试

**Files:**
- Modify: `Luminous/test/auth/auth_widgets_test.dart`

- [ ] **Step 1: 在 auth_widgets_test.dart 末尾(main 闭合括号前)追加密码可见切换测试**

打开 `Luminous/test/auth/auth_widgets_test.dart`,在 `main()` 函数内最后一个 `testWidgets` 结束后(第 83 行 `});` 之后、第 84 行 `}` 之前)追加:

```dart

  testWidgets('AuthTextField password field toggles visibility', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: AuthTextField(
                controller: controller,
                label: 'Password',
                obscureText: true,
                prefix: const Icon(Icons.lock_outline),
              ),
            ),
          ),
        ),
      ),
    );

    // 初始: 密码被遮蔽,显示 visibility 图标。
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

    // 点击切换。
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    // 切换后: 密码可见,显示 visibility_off 图标。
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
  });

  testWidgets('AuthBrandLogo renders asset image', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: AuthBrandLogo())),
      ),
    );

    // Logo 容器存在; 图片资源在测试环境可能加载失败,但 errorBuilder 保证不崩溃。
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });

  testWidgets('AuthShell renders logo and subtitle when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AuthShell(
            title: 'Sign in',
            subtitle: 'My subtitle',
            logo: const AuthBrandLogo(),
            form: const Column(
              children: [Text('form body')],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('My subtitle'), findsOneWidget);
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });
```

> 注意:`AuthShell` 内部有 `SingleChildScrollView` + `SafeArea`,在测试中需足够大视口。`MaterialApp` + `Scaffold` 默认视口够用。

- [ ] **Step 2: 运行测试**

```bash
cd Luminous && flutter test test/auth/auth_widgets_test.dart
```

预期:全部通过(原有 2 个 + 新增 3 个 = 5 个测试)。

- [ ] **Step 3: 提交**

```bash
cd Luminous && git add test/auth/auth_widgets_test.dart && git commit -m "test(auth): 补充 logo/subtitle/密码切换的 widget 测试"
```

---

## Task 10: 全量验证 + 文档

**Files:**
- Create: `Luminous/docs/migration-log/2026-06-23.md`

- [ ] **Step 1: 跑全量 analyze**

```bash
cd Luminous && flutter analyze
```

预期:无新增 error/warning(原有问题保持不变)。

- [ ] **Step 2: 跑全量 test**

```bash
cd Luminous && flutter test
```

预期:全部通过。若有 snapshot/golden 测试因 UI 变化失败,更新对应 golden(`flutter test --update-goldens`,但本项目应无 golden 测试)。

- [ ] **Step 3: 写迁移日志**

创建 `Luminous/docs/migration-log/2026-06-23.md`:

```markdown
# 2026-06-23 Auth 页面视觉优化

## 改动概述

为登录、注册、忘记密码三个 auth 页面增加品牌识别度与亲和力,在保留现有渐变背景、白色卡片、阴影、动画的基础上补充:

- **品牌 Logo**: 标题区顶部展示 `AuthBrandLogo`(浅灰圆角容器包裹 app icon)
- **欢迎副标题**: 登录用"欢迎回来"+ "登录以继续你的健康记录",注册用"加入 Luminous...",忘记密码用"我们将发送验证码..."
- **字段前缀图标**: 邮箱(mail)、密码(lock)、昵称(person)、WeChat 回调(link)
- **密码可见切换**: 密码字段自动注入可见性 toggle(eye icon),无需页面层处理
- **服务条款提示**: 注册页主按钮下方"创建即表示同意《服务条款》与《隐私政策》",当前点击用 toast 占位

## 受影响文件

- `lib/features/auth/presentation/widgets/auth_shell.dart`
  - `AuthShell` 新增 `logo` / `subtitle` 槽,标题区支持三段式纵向布局
  - `AuthTextField` 新增 `prefix` 槽;密码字段自治可见性切换(新增 `_obscured` 状态)
  - 新增 `AuthBrandLogo` widget
  - 新增 `AuthTermsNotice` widget
- `lib/features/auth/presentation/pages/login_page.dart` — 接入 logo/subtitle/prefix,标题改用 `authWelcomeBack`
- `lib/features/auth/presentation/pages/register_page.dart` — 接入 logo/subtitle/prefix + 服务条款
- `lib/features/auth/presentation/pages/forgot_password_page.dart` — 接入 logo/subtitle/prefix

## 新增 l10n key

| key | en | zh |
|---|---|---|
| `authLoginSubtitle` | Sign in to continue your health tracking | 登录以继续你的健康记录 |
| `authRegisterSubtitle` | Join Luminous and start your health journal | 加入 Luminous,开启你的健康记录 |
| `authForgotPasswordSubtitle` | We'll send a code to reset your password | 我们将发送验证码以重置你的密码 |
| `authTermsAgreement` | By creating an account, you agree to the {terms} and {privacy} | 创建即表示同意{terms}与{privacy} |
| `authTermsOfService` | Terms of Service | 服务条款 |
| `authPrivacyPolicy` | Privacy Policy | 隐私政策 |
| `authTermsComingSoonToast` | Terms and privacy policy will be available soon. | 服务条款与隐私政策即将上线。 |

> `authWelcomeBack`("Welcome back"/"欢迎回来")此前已存在于 ARB 但未被使用,本次正式启用为登录主标题。

## 设计决策

- 纯视觉改动,不动 data/provider/OAuth/路由逻辑
- 颜色、间距、圆角、阴影全部复用 `app_design.dart` 与 `AppThemeSurface` token,兼容 light/dark/classic/bluePink/yellowGreen 全部主题变体
- 字段图标用 Material Icons 而非 emoji,保证跨平台一致性
- 服务条款/隐私政策暂用 toast 占位,待协议页面落地后替换 `AuthTermsNotice` 的回调

## 验证

- `flutter analyze`: 无新增 warning
- `flutter test`: 全部通过(auth widget 测试新增 3 个用例)
```

- [ ] **Step 4: 清理临时 spec 文件**

实现完成后,删除 `Luminous/plans/2026-06-23-auth-pages-visual-refresh.md`(按 `Luminous/plans/README.md` 约定,完成的 plan 应删除,决策折叠进 docs)。

```bash
cd Luminous && git rm plans/2026-06-23-auth-pages-visual-refresh.md
```

> 注意:仅当所有任务完成且验证通过后才执行此步。

- [ ] **Step 5: 提交文档与清理**

```bash
cd Luminous && git add docs/migration-log/2026-06-23.md && git commit -m "docs(auth): 记录 auth 视觉优化的迁移日志并清理 plan"
```

---

## Self-Review 记录

**Spec 覆盖检查:**
- ✅ 改动 1(AuthShell 扩展 logo/subtitle)— Task 2
- ✅ 改动 2(AuthTextField 加 prefix)— Task 4 Step 1
- ✅ 改动 3(密码可见切换)— Task 4 Step 2-3
- ✅ 改动 4(注册页服务条款)— Task 5 + Task 7 Step 5
- ✅ 改动 5(欢迎文案 l10n)— Task 1
- ✅ 改动 6(忘记密码页同步)— Task 8

**类型一致性检查:**
- `AuthBrandLogo({this.size = 64})` — Task 3 定义,Task 6/7/8 用 `const AuthBrandLogo()` ✅
- `AuthTermsNotice({required onTerms, required onPrivacy})` — Task 5 定义,Task 7 用具名参数 ✅
- `AuthShell({logo, subtitle, ...})` — Task 2 定义,Task 6/7/8 用 logo + subtitle ✅
- `AuthTextField({prefix, suffix, ...})` — Task 4 定义,Task 6/7/8 用 prefix ✅

**占位符扫描:** 无 TBD/TODO,所有代码块完整。
