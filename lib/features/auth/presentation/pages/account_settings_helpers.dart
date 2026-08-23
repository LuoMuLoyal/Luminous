import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_sections.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Profile section — nickname and avatar editing within the account
/// settings page.
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.nicknameController,
    required this.avatarController,
    required this.isSubmitting,
    required this.onSave,
  });

  final TextEditingController nicknameController;
  final TextEditingController avatarController;
  final bool isSubmitting;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authProfileSectionTitle,
          style: TypographyToken.level5
              .body(context)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.level5),
        // Avatar preview
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: avatarController,
          builder: (context, value, _) {
            final url = value.text.trim();
            final isValidUrl =
                url.isEmpty ||
                (Uri.tryParse(url)?.hasAbsolutePath == true &&
                    (url.startsWith('http://') || url.startsWith('https://')));
            return Row(
              children: [
                FAvatar.raw(
                  size: 56,
                  child: url.isNotEmpty && isValidUrl
                      ? ClipOval(
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                            errorBuilder: (_, __, ___) =>
                                const Icon(SemanticIcons.profileUser, size: 28),
                          ),
                        )
                      : const Icon(SemanticIcons.profileUser, size: 28),
                ),
                const SizedBox(width: Spacing.level4),
                Expanded(
                  child: Text(
                    url.isEmpty
                        ? l10n.authAvatarPreviewEmpty
                        : isValidUrl
                        ? l10n.authAvatarPreviewReady
                        : l10n.authAvatarPreviewInvalid,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(
                          color: url.isEmpty || isValidUrl
                              ? colors.mutedForeground
                              : colors.destructive,
                        ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: Spacing.level4),
        FTextField(
          control: FTextFieldControl.managed(controller: nicknameController),
          label: Text(l10n.authNicknameLabel),
          hint: l10n.authNicknameHint,
        ),
        const SizedBox(height: Spacing.level4),
        FTextField(
          control: FTextFieldControl.managed(controller: avatarController),
          label: Text(l10n.authAvatarLabel),
          hint: l10n.authAvatarHint,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: Spacing.level4),
        SizedBox(
          width: double.infinity,
          child: FButton(
            onPress: isSubmitting ? null : () => onSave(),
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: FCircularProgress(),
                  )
                : Text(l10n.authProfileSaveAction),
          ),
        ),
      ],
    );
  }
}

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

/// Shows the latest account operation error, translating an invalid security
/// elevation into the action the user needs to take next.
Future<void> showAuthAccountFailureToast(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final state = ref.read(authAccountProvider);
  final message = state.requiresSecurityElevation
      ? l10n.authSecurityElevationRequiredToast
      : state.errorMessage?.isNotEmpty == true
      ? state.errorMessage
      : null;
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
          style: TypographyToken.level6
              .body(context)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.level4),
        Text(
          l10n.authIdentityUnlinkConfirmMessage(
            identityProviderLabel(identity.provider, l10n),
          ),
          style: TypographyToken.level4.body(context),
        ),
        const SizedBox(height: Spacing.level6),
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
            const SizedBox(width: Spacing.level3),
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
