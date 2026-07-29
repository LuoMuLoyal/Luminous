import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
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

/// Sends a verification code, prompts for the code, and verifies the email.
Future<void> verifyEmailFlow(
  BuildContext context,
  AppLocalizations l10n,
  WidgetRef ref,
  String email,
) async {
  final notifier = ref.read(authAccountProvider.notifier);
  final sent = await notifier.sendVerificationCode(
    email: email,
    scene: AuthVerificationScene.register,
  );
  if (!context.mounted) return;
  if (!sent) {
    final state = ref.read(authAccountProvider);
    final msg = state.errorMessage?.isNotEmpty == true
        ? state.errorMessage!
        : l10n.authEmailRequiredError;
    await Toast.show(context, msg);
    return;
  }

  await Toast.show(context, l10n.authSendCode);
  if (!context.mounted) return;

  final code = await showVerifyEmailDialog(context, l10n);
  if (code == null || !context.mounted) return;

  final ok = await notifier.verifyEmail(email: email, code: code);
  if (!context.mounted) return;
  if (ok) {
    await Toast.show(context, l10n.authEmailVerifiedAt(email));
  } else {
    final state = ref.read(authAccountProvider);
    final msg = state.errorMessage?.isNotEmpty == true
        ? state.errorMessage!
        : l10n.authCodeRequiredError;
    await Toast.show(context, msg);
  }
}

/// Shows a dialog for entering the email verification code.
Future<String?> showVerifyEmailDialog(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final controller = TextEditingController();
  final result = await showAppDialog<String>(
    context: context,
    maxWidth: LayoutScaleResolver.wideDialogMaxWidthFor(
      MediaQuery.sizeOf(context).width,
    ),
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authEmailVerifyAction,
          style: TypographyToken.level6
              .body(dialogContext)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.level4),
        FTextField(
          control: FTextFieldControl.managed(controller: controller),
          label: Text(l10n.authCodeLabel),
          hint: l10n.authCodeLabel,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        const SizedBox(height: Spacing.level6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.authCancelAction),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(l10n.authEmailVerifyAction),
            ),
          ],
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
