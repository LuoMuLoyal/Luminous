import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/pages/account_identity.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Starts the WeChat identity link flow — delegates to the account notifier
/// and shows a toast with the result.
Future<void> startWechatIdentityLink(
  BuildContext context,
  AppLocalizations l10n,
  WidgetRef ref,
) async {
  final result = await ref
      .read(authAccountProvider.notifier)
      .startWechatIdentityLink(webCallbackUri: webWechatLinkCallbackUri());
  if (!context.mounted || result == null) return;
  switch (result) {
    case WechatIdentityLinkResult.completed:
      await Toast.show(context, l10n.authIdentityLinkSuccess);
    case WechatIdentityLinkResult.opened:
      await Toast.show(context, l10n.authWechatAuthorizeOpened);
    case WechatIdentityLinkResult.unsupported:
      await Toast.show(context, l10n.authIdentityLinkUnsupported);
  }
}

/// Shows the latest account operation error, translating special problem
/// codes into the action the user needs to take next.
Future<void> showAuthAccountFailureToast(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final state = ref.read(authAccountProvider);
  final String? message;
  if (state.errorCode == LucentFailure.kPasswordNotSetCode) {
    message = l10n.authPasswordNotSetToast;
  } else {
    message = state.errorMessage?.isNotEmpty == true
        ? state.errorMessage
        : null;
  }
  if (message == null || !context.mounted) return;
  await Toast.show(context, message);
}

/// Returns the OAuth callback URI for WeChat web identity link, or null on
/// non-web platforms.
String? webWechatLinkCallbackUri() {
  if (!kIsWeb) return null;
  final base = Uri.base;
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: '/account/oauth/wechat',
  ).toString();
}

/// Shows a confirmation dialog before unlinking an identity.
Future<bool> confirmUnlinkIdentity(
  BuildContext context,
  AuthLinkedIdentity identity,
  AppLocalizations l10n,
) async {
  final result = await showAppDialog<bool>(
    context: context,
    maxWidth: LayoutScaleResolver.wideDialogMaxWidthFor(
      MediaQuery.sizeOf(context).width,
    ),
    scrollable: false,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authIdentityUnlinkConfirmTitle,
          style: context.theme.typography.body.lg.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Text(
          l10n.authIdentityUnlinkConfirmMessage(
            identityProviderLabel(identity.provider, l10n),
          ),
          style: context.theme.typography.body.sm,
        ),
        const SizedBox(height: Spacing.xl2),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () => Navigator.of(context).pop(false),
              child: Text(l10n.authCancelAction),
            ),
            const SizedBox(width: Spacing.md),
            FButton(
              variant: FButtonVariant.destructive,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () => Navigator.of(context).pop(true),
              child: Text(l10n.authIdentityUnlinkAction),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Informs the user that email verification is done via the link in the
/// verification email. Better Auth requires a token from that link; the
/// app consumes it on the deep-link route when the user taps the email.
Future<void> verifyEmailFlow(
  BuildContext context,
  AppLocalizations l10n,
  WidgetRef ref,
  String email,
) async {
  await Toast.show(context, l10n.authEmailVerifyLinkHint);
}
