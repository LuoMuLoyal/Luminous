import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

const double _authControlHeight = 56;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final layout = AppLayoutTokens.resolve(width);
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);

    return Scaffold(
      backgroundColor: surface.canvasSoft,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColorTokens.canvas, surface.canvasSoft],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: layout.pageHorizontalPadding,
              vertical: width < AppBreakpoints.mobile
                  ? AppSpacingTokens.lg
                  : AppSpacingTokens.xl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AuthPageHeader(
                      title: title,
                      leading: leading,
                      centerTitle: centerTitle,
                      typography: typography,
                      logo: logo,
                      subtitle: subtitle,
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),
                    _AuthFormPanel(
                      form: form,
                      surface: surface,
                      enableAnimation: enableFormAnimation,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
        Text(title, textAlign: TextAlign.center, style: typography.displaySm),
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

class AuthSectionCard extends StatelessWidget {
  const AuthSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: child,
      ),
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({
    required this.form,
    required this.surface,
    required this.enableAnimation,
  });

  final Widget form;
  final AppThemeSurface surface;
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level4,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.xl),
        child: form,
      ),
    );

    if (!enableAnimation) {
      return panel;
    }

    return panel
        .animate()
        .fadeIn(duration: 180.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.03,
          end: 0,
          duration: 180.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

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

class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focusNode;
  bool _obscured = false;

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
    final iconColor = _focusNode.hasFocus
        ? theme.colorScheme.primary
        : surface.mute;

    // 密码字段: 若外部未自定义 suffix,自动注入可见性切换按钮。
    final Widget? effectiveSuffix =
        widget.suffix ??
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
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
}

class _AuthControlFrame extends StatelessWidget {
  const _AuthControlFrame({
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadiusTokens.sm);

    return SizedBox(
      height: _authControlHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: Border.all(color: borderColor),
        ),
        child: ClipRRect(borderRadius: borderRadius, child: child),
      ),
    );
  }
}

class AuthStatusMessage extends StatelessWidget {
  const AuthStatusMessage({super.key, this.error, this.success});

  final String? error;
  final String? success;

  @override
  Widget build(BuildContext context) {
    final message = error?.isNotEmpty == true
        ? error
        : success?.isNotEmpty == true
        ? success
        : null;
    if (message == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final isError = error?.isNotEmpty == true;
    final color = isError ? theme.colorScheme.error : surface.success;

    return Text(message, style: typography.bodySm.copyWith(color: color));
  }
}

class AuthCodeFieldRow extends StatelessWidget {
  const AuthCodeFieldRow({
    super.key,
    required this.controller,
    required this.label,
    required this.buttonLabel,
    required this.onSendCode,
    this.isLoading = false,
    this.keyboardType = TextInputType.number,
  });

  final TextEditingController controller;
  final String label;
  final String buttonLabel;
  final VoidCallback? onSendCode;
  final bool isLoading;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final isEnabled = onSendCode != null && !isLoading;

    return SizedBox(
      height: _authControlHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AuthTextField(
              key: const ValueKey('auth-code-field-input'),
              controller: controller,
              label: label,
              keyboardType: keyboardType,
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          SizedBox(
            key: const ValueKey('auth-code-field-button'),
            width: 132,
            child: _AuthControlFrame(
              backgroundColor: surface.canvas,
              borderColor: surface.hairline,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? onSendCode : null,
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            buttonLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.buttonLg.copyWith(
                              color: isEnabled ? surface.link : surface.mute,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthLoginActionRow extends StatelessWidget {
  const AuthLoginActionRow({
    super.key,
    required this.registerPrompt,
    required this.registerLabel,
    required this.onRegister,
    required this.forgotPasswordLabel,
    required this.onForgotPassword,
  });

  final String registerPrompt;
  final String registerLabel;
  final VoidCallback onRegister;
  final String forgotPasswordLabel;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final promptStyle = typography.bodySm.copyWith(color: surface.body);
    final linkStyle = typography.bodySm.copyWith(
      color: surface.link,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 0,
            children: [
              Text(registerPrompt, style: promptStyle),
              TextButton(
                onPressed: onRegister,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(registerLabel, style: linkStyle),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(forgotPasswordLabel, style: linkStyle),
        ),
      ],
    );
  }
}

class AuthFooterAction extends StatelessWidget {
  const AuthFooterAction({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacingTokens.xs,
      children: [
        Text(prompt, style: typography.bodySm.copyWith(color: surface.body)),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.xs,
            ),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final typography = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(Theme.of(context).colorScheme.onPrimary)
        : AppTypographyTokens.desktop(Theme.of(context).colorScheme.onPrimary);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(_authControlHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label, style: typography.buttonLg),
      ),
    );
  }
}

/// Auth 页面品牌 Logo。用浅灰圆角渐变容器包裹白色 app icon,
/// 解决白底图标与白色卡片背景融合的问题,并增加层次感。
class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({super.key, this.size = 64});

  final double size;

  static const String _assetPath = 'assets/icons/luminous_app_icon.png';

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final theme = Theme.of(context);

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
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.health_and_safety_rounded,
            color: theme.colorScheme.primary,
            size: size - AppSpacingTokens.sm * 2,
          ),
        ),
      ),
    );
  }
}

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
    final linkButtonStyle = TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 28),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final String leadText =
        l10n?.authTermsAgreement('', '') ??
        'By creating an account, you agree to the ';
    final String connector = l10n?.localeName.startsWith('zh') == true
        ? '与'
        : ' and ';
    final String termsLabel = l10n?.authTermsOfService ?? 'Terms of Service';
    final String privacyLabel = l10n?.authPrivacyPolicy ?? 'Privacy Policy';

    // 裁剪 leadText 末尾残留的占位符空位:英文 "agree to the  and " → "agree to the "
    final String trimmedLead = leadText.trimRight().replaceAll(
      RegExp(r'\s+(and|与)\s*$'),
      '',
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xs),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            Text(
              trimmedLead,
              style: typography.bodySm.copyWith(color: surface.body),
            ),
            TextButton(
              onPressed: onTerms,
              style: linkButtonStyle,
              child: Text(termsLabel, style: linkStyle),
            ),
            Text(
              connector,
              style: typography.bodySm.copyWith(color: surface.body),
            ),
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
