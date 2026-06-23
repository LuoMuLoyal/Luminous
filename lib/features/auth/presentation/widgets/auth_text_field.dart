import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

const double _authControlHeight = 56;

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
