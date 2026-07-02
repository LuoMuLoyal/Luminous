import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

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
    final colors = context.theme.colors;
    final textTheme = theme.textTheme;
    final borderColor = _focusNode.hasFocus
        ? theme.colorScheme.primary
        : colors.border;
    final contentColor = widget.enabled
        ? theme.colorScheme.onSurface
        : colors.mutedForeground;
    final iconColor = _focusNode.hasFocus
        ? theme.colorScheme.primary
        : colors.mutedForeground;

    // 密码字段: 若外部未自定义 suffix,自动注入可见性切换按钮。
    final Widget? effectiveSuffix =
        widget.suffix ??
        (widget.obscureText
            ? IconButton(
                onPressed: _toggleObscure,
                icon: Icon(
                  _obscured ? FLucideIcons.eye : FLucideIcons.eyeOff,
                  size: 20,
                ),
                color: iconColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: _obscured ? 'Show password' : 'Hide password',
              )
            : null);

    return _AuthControlFrame(
      backgroundColor: widget.enabled
          ? colors.background
          : colors.secondary.withValues(alpha: 0.42),
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
                  style: textTheme.bodyMedium?.copyWith(color: contentColor),
                  cursorColor: theme.colorScheme.primary,
                  decoration: InputDecoration.collapsed(
                    hintText: widget.label,
                    hintStyle: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
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
              backgroundColor: colors.background,
              borderColor: colors.border,
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
                            style: textTheme.labelLarge?.copyWith(
                              color: isEnabled
                                  ? colors.primary
                                  : colors.mutedForeground,
                              fontWeight: FontWeight.w600,
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
