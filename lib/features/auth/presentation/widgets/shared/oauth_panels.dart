import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// WeChat OAuth panel: start button + manual callback input.
///
/// Watches [isStarting] / [isCompleting] for loading state and
/// [authorizeUrl] for showing the callback input field.
class WechatOAuthPanel extends StatelessWidget {
  const WechatOAuthPanel({
    super.key,
    required this.callbackController,
    required this.isStarting,
    required this.isCompleting,
    required this.authorizeUrl,
    required this.onStart,
    required this.onComplete,
  });

  final TextEditingController callbackController;
  final bool isStarting;
  final bool isCompleting;
  final String? authorizeUrl;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FButton(
          key: const Key('wechat-login-start-button'),
          variant: FButtonVariant.outline,
          onPress: isStarting || isCompleting ? null : onStart,
          child: isStarting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: FCircularProgress(),
                )
              : Text(l10n.authWechatSignIn),
        ),
        if (authorizeUrl?.isNotEmpty == true) ...[
          const SizedBox(height: Spacing.level4),
          FTextField(
            key: const Key('wechat-callback-input'),
            control: FTextFieldControl.managed(controller: callbackController),
            label: Text(l10n.authWechatCallbackLabel),
            hint: l10n.authWechatCallbackHint,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: Spacing.level4),
          SizedBox(
            width: double.infinity,
            child: FButton(
              onPress: isCompleting ? null : onComplete,
              child: isCompleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: FCircularProgress(),
                    )
                  : Text(l10n.authWechatCompleteAction),
            ),
          ),
        ],
      ],
    );
  }
}

/// QQ OAuth panel: start button + manual callback input.
class QqOAuthPanel extends StatelessWidget {
  const QqOAuthPanel({
    super.key,
    required this.callbackController,
    required this.isStarting,
    required this.isCompleting,
    required this.authorizeUrl,
    required this.onStart,
    required this.onComplete,
  });

  final TextEditingController callbackController;
  final bool isStarting;
  final bool isCompleting;
  final String? authorizeUrl;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.level4),
        FButton(
          key: const Key('qq-login-start-button'),
          variant: FButtonVariant.outline,
          onPress: isStarting || isCompleting ? null : onStart,
          child: isStarting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: FCircularProgress(),
                )
              : Text(l10n.authQqSignIn),
        ),
        if (authorizeUrl?.isNotEmpty == true) ...[
          const SizedBox(height: Spacing.level4),
          FTextField(
            key: const Key('qq-callback-input'),
            control: FTextFieldControl.managed(controller: callbackController),
            label: Text(l10n.authQqCallbackLabel),
            hint: l10n.authQqCallbackHint,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: Spacing.level4),
          SizedBox(
            width: double.infinity,
            child: FButton(
              onPress: isCompleting ? null : onComplete,
              child: isCompleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: FCircularProgress(),
                    )
                  : Text(l10n.authQqCompleteAction),
            ),
          ),
        ],
      ],
    );
  }
}

/// Apple Sign In panel. Auto-hides when Apple Sign In is unavailable.
class AppleOAuthPanel extends StatefulWidget {
  const AppleOAuthPanel({
    super.key,
    required this.isLoading,
    required this.onSignIn,
  });

  final bool isLoading;
  final VoidCallback onSignIn;

  @override
  State<AppleOAuthPanel> createState() => _AppleOAuthPanelState();
}

class _AppleOAuthPanelState extends State<AppleOAuthPanel> {
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final available = await SignInWithApple.isAvailable();
    if (mounted) {
      setState(() => _isAvailable = available);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: Spacing.level4),
      child: AbsorbPointer(
        absorbing: widget.isLoading,
        child: SignInWithAppleButton(onPressed: widget.onSignIn),
      ),
    );
  }
}
