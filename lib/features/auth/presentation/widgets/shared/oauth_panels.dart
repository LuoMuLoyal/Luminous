import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Brand identity colors for OAuth providers.
///
/// These are fixed brand colors, not theme-adaptive — they represent
/// each provider's official brand guideline and must not change with
/// the app theme.
abstract final class OAuthBrandColors {
  /// WeChat green — #07C160.
  static const Color wechat = Color(0xFF07C160);

  /// Tencent QQ blue — #12B7F5.
  static const Color qq = Color(0xFF12B7F5);

  /// Weibo red — #E6162D.
  static const Color weibo = Color(0xFFE6162D);

  /// Google blue — #4285F4.
  static const Color google = Color(0xFF4285F4);

  /// Apple black — #000000.
  static const Color apple = Color(0xFF000000);
}

/// OAuth login section: "其他方式登录" divider + row of circular
/// brand-colored icon buttons + optional callback input fields.
class OAuthButtonRow extends StatefulWidget {
  const OAuthButtonRow({
    super.key,
    required this.wechatCallbackController,
    required this.isStartingWechat,
    required this.isCompletingWechat,
    required this.wechatAuthorizeUrl,
    required this.onWechatStart,
    required this.onWechatComplete,
    required this.qqCallbackController,
    required this.isStartingQq,
    required this.isCompletingQq,
    required this.qqAuthorizeUrl,
    required this.onQqStart,
    required this.onQqComplete,
    required this.weiboCallbackController,
    required this.isStartingWeibo,
    required this.isCompletingWeibo,
    required this.weiboAuthorizeUrl,
    required this.onWeiboStart,
    required this.onWeiboComplete,
    required this.googleCallbackController,
    required this.isStartingGoogle,
    required this.isCompletingGoogle,
    required this.googleAuthorizeUrl,
    required this.onGoogleStart,
    required this.onGoogleComplete,
    required this.isStartingApple,
    required this.onAppleSignIn,
  });

  // WeChat
  final TextEditingController wechatCallbackController;
  final bool isStartingWechat;
  final bool isCompletingWechat;
  final String? wechatAuthorizeUrl;
  final VoidCallback onWechatStart;
  final VoidCallback onWechatComplete;

  // QQ
  final TextEditingController qqCallbackController;
  final bool isStartingQq;
  final bool isCompletingQq;
  final String? qqAuthorizeUrl;
  final VoidCallback onQqStart;
  final VoidCallback onQqComplete;

  // Weibo
  final TextEditingController weiboCallbackController;
  final bool isStartingWeibo;
  final bool isCompletingWeibo;
  final String? weiboAuthorizeUrl;
  final VoidCallback onWeiboStart;
  final VoidCallback onWeiboComplete;

  // Google
  final TextEditingController googleCallbackController;
  final bool isStartingGoogle;
  final bool isCompletingGoogle;
  final String? googleAuthorizeUrl;
  final VoidCallback onGoogleStart;
  final VoidCallback onGoogleComplete;

  // Apple
  final bool isStartingApple;
  final VoidCallback onAppleSignIn;

  @override
  State<OAuthButtonRow> createState() => _OAuthButtonRowState();
}

class _OAuthButtonRowState extends State<OAuthButtonRow> {
  bool _appleAvailable = false;

  @override
  void initState() {
    super.initState();
    unawaited(_checkAppleAvailability());
  }

  Future<void> _checkAppleAvailability() async {
    try {
      final available = await SignInWithApple.isAvailable();
      if (mounted) setState(() => _appleAvailable = available);
    } catch (e) {
      appTalker.debug(
        'OAuthButtonRow: Apple Sign In availability check failed: $e',
      );
      // Platform channel unavailable — Apple Sign In not supported.
      if (mounted) setState(() => _appleAvailable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "其他方式登录" divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.level5),
          child: Row(
            children: [
              Expanded(
                child: Divider(color: SemanticColor.neutral.border(context)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.level4),
                child: Text(
                  l10n.authOrOtherLogin,
                  style: context.theme.typography.body.xs2.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: SemanticColor.neutral.border(context)),
              ),
            ],
          ),
        ),
        // Circular brand-colored button row
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OAuthCircleButton(
                buttonKey: const Key('wechat-login-start-button'),
                assetPath: 'assets/icon/oauth/wechat.svg',
                backgroundColor: OAuthBrandColors.wechat,
                isLoading: widget.isStartingWechat,
                disabled: widget.isStartingWechat || widget.isCompletingWechat,
                onPressed: widget.onWechatStart,
              ),
              const SizedBox(width: Spacing.level4),
              _OAuthCircleButton(
                buttonKey: const Key('qq-login-start-button'),
                assetPath: 'assets/icon/oauth/qq.svg',
                backgroundColor: OAuthBrandColors.qq,
                isLoading: widget.isStartingQq,
                disabled: widget.isStartingQq || widget.isCompletingQq,
                onPressed: widget.onQqStart,
              ),
              const SizedBox(width: Spacing.level4),
              _OAuthCircleButton(
                buttonKey: const Key('weibo-login-start-button'),
                assetPath: 'assets/icon/oauth/weibo.svg',
                backgroundColor: OAuthBrandColors.weibo,
                isLoading: widget.isStartingWeibo,
                disabled: widget.isStartingWeibo || widget.isCompletingWeibo,
                onPressed: widget.onWeiboStart,
              ),
              const SizedBox(width: Spacing.level4),
              _OAuthCircleButton(
                buttonKey: const Key('google-login-start-button'),
                assetPath: 'assets/icon/oauth/google.svg',
                backgroundColor: OAuthBrandColors.google,
                isLoading: widget.isStartingGoogle,
                disabled: widget.isStartingGoogle || widget.isCompletingGoogle,
                onPressed: widget.onGoogleStart,
              ),
              if (_appleAvailable) ...[
                const SizedBox(width: Spacing.level4),
                _OAuthCircleButton(
                  buttonKey: const Key('apple-login-start-button'),
                  assetPath: 'assets/icon/oauth/apple.svg',
                  backgroundColor: OAuthBrandColors.apple,
                  isLoading: widget.isStartingApple,
                  disabled: widget.isStartingApple,
                  onPressed: widget.onAppleSignIn,
                ),
              ],
            ],
          ),
        ),
        // WeChat callback input (shown when authorizeUrl is set)
        if (widget.wechatAuthorizeUrl?.isNotEmpty == true) ...[
          const SizedBox(height: Spacing.level4),
          FTextField(
            key: const Key('wechat-callback-input'),
            control: FTextFieldControl.managed(
              controller: widget.wechatCallbackController,
            ),
            label: Text(l10n.authWechatCallbackLabel),
            hint: l10n.authWechatCallbackHint,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: Spacing.level3),
          FButton(
            key: const Key('wechat-complete-button'),
            onPress: widget.isCompletingWechat ? null : widget.onWechatComplete,
            size: FButtonSizeVariant.sm,
            child: widget.isCompletingWechat
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: FCircularProgress(),
                  )
                : Text(l10n.authWechatCompleteAction),
          ),
        ],
        // QQ callback input (shown when authorizeUrl is set)
        if (widget.qqAuthorizeUrl?.isNotEmpty == true) ...[
          const SizedBox(height: Spacing.level4),
          FTextField(
            key: const Key('qq-callback-input'),
            control: FTextFieldControl.managed(
              controller: widget.qqCallbackController,
            ),
            label: Text(l10n.authQqCallbackLabel),
            hint: l10n.authQqCallbackHint,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: Spacing.level3),
          FButton(
            key: const Key('qq-complete-button'),
            onPress: widget.isCompletingQq ? null : widget.onQqComplete,
            size: FButtonSizeVariant.sm,
            child: widget.isCompletingQq
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: FCircularProgress(),
                  )
                : Text(l10n.authQqCompleteAction),
          ),
        ],
        // Weibo callback input (shown when authorizeUrl is set)
        if (widget.weiboAuthorizeUrl?.isNotEmpty == true) ...[
          const SizedBox(height: Spacing.level4),
          FTextField(
            key: const Key('weibo-callback-input'),
            control: FTextFieldControl.managed(
              controller: widget.weiboCallbackController,
            ),
            label: Text(l10n.authWeiboCallbackLabel),
            hint: l10n.authWeiboCallbackHint,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: Spacing.level3),
          FButton(
            key: const Key('weibo-complete-button'),
            onPress: widget.isCompletingWeibo ? null : widget.onWeiboComplete,
            size: FButtonSizeVariant.sm,
            child: widget.isCompletingWeibo
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: FCircularProgress(),
                  )
                : Text(l10n.authWeiboCompleteAction),
          ),
        ],
        // Google callback input (shown when authorizeUrl is set)
        if (widget.googleAuthorizeUrl?.isNotEmpty == true) ...[
          const SizedBox(height: Spacing.level4),
          FTextField(
            key: const Key('google-callback-input'),
            control: FTextFieldControl.managed(
              controller: widget.googleCallbackController,
            ),
            label: Text(l10n.authGoogleCallbackLabel),
            hint: l10n.authGoogleCallbackHint,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: Spacing.level3),
          FButton(
            key: const Key('google-complete-button'),
            onPress: widget.isCompletingGoogle ? null : widget.onGoogleComplete,
            size: FButtonSizeVariant.sm,
            child: widget.isCompletingGoogle
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: FCircularProgress(),
                  )
                : Text(l10n.authGoogleCompleteAction),
          ),
        ],
      ],
    );
  }
}

/// A single circular OAuth provider button with brand color background
/// and white SVG icon. Shows a loading spinner when [isLoading] is true.
class _OAuthCircleButton extends StatelessWidget {
  const _OAuthCircleButton({
    this.buttonKey,
    required this.assetPath,
    required this.backgroundColor,
    required this.isLoading,
    required this.disabled,
    required this.onPressed,
  });

  final Key? buttonKey;
  final String assetPath;
  final Color backgroundColor;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: buttonKey,
      onTap: disabled ? null : onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: disabled ? 0.4 : 1.0),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isLoading
              ? const ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: FCircularProgress(),
                  ),
                )
              : SvgPicture.asset(
                  assetPath,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
        ),
      ),
    );
  }
}
