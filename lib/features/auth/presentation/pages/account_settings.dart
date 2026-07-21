import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_sections.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/shell.dart';
import 'package:luminous/l10n/app_localizations.dart';
export 'account_settings_sections.dart';

class AccountSettingsPage extends HookConsumerWidget {
  const AccountSettingsPage({
    super.key,
    this.enableFormAnimation = true,
    this.wechatCode,
    this.wechatState,
  });
  final bool enableFormAnimation;
  final String? wechatCode;
  final String? wechatState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final accountState = ref.watch(authAccountProvider);
    final accountNotifier = ref.read(authAccountProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final user = session.user;
    final resolvingSession = session.isLoading;
    final signedOut = !session.canAccessProtectedData || user == null;

    final emailController = useTextEditingController(text: user?.email ?? '');
    final nicknameController = useTextEditingController(
      text: user?.nickname ?? '',
    );
    final avatarController = useTextEditingController(text: user?.avatar ?? '');
    final oldPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final deletePasswordController = useTextEditingController();
    final deleteCodeController = useTextEditingController();
    final formUserId = useRef<String?>(null);
    final wechatIdentityLinkStarted = useRef(false);

    // Sync controllers when user changes
    useEffect(() {
      if (user == null || formUserId.value == user.id) return null;
      formUserId.value = user.id;
      emailController.text = user.email ?? '';
      nicknameController.text = user.nickname ?? '';
      avatarController.text = user.avatar ?? '';
      return null;
    }, [user?.id]);

    Future<void> completeWechatIdentityLink(String code, String state) async {
      final ok = await ref
          .read(authAccountProvider.notifier)
          .completeWechatWebIdentityLink(code: code, state: state);
      if (!context.mounted) return;
      if (ok) {
        await Toast.show(context, l10n.authIdentityLinkSuccess);
        if (context.mounted) context.go(Routes.account);
      }
    }

    void maybeCompleteWechatIdentityLink() {
      if (wechatIdentityLinkStarted.value ||
          wechatCode?.isNotEmpty != true ||
          wechatState?.isNotEmpty != true) {
        return;
      }
      final s = ref.read(authSessionProvider);
      if (s.isLoading) return;
      wechatIdentityLinkStarted.value = true;
      if (!s.canAccessProtectedData) {
        context.go(loginRouteForReturnTo('/account'));
        return;
      }
      unawaited(completeWechatIdentityLink(wechatCode!, wechatState!));
    }

    // Handle OAuth callback on first build
    useEffect(() {
      if ((wechatCode?.isNotEmpty ?? false) &&
          (wechatState?.isNotEmpty ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          maybeCompleteWechatIdentityLink();
        });
      }
      return null;
    }, []);

    // Handle OAuth in subsequent builds
    if ((wechatCode?.isNotEmpty ?? false) &&
        (wechatState?.isNotEmpty ?? false) &&
        !wechatIdentityLinkStarted.value &&
        !session.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        maybeCompleteWechatIdentityLink();
      });
    }

    return AuthShell(
      title: l10n.authAccountSettingsFormTitle,
      leading: const AppBackButton(),
      centerTitle: true,
      enableFormAnimation: enableFormAnimation,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (resolvingSession) ...[
            const AccountSettingsLoading(),
          ] else if (signedOut) ...[
            AuthRequiredDialogGate(
              onLogin: () =>
                  context.push(loginRouteForCurrentLocation(context)),
            ),
          ] else ...[
            FTabs(
              children: [
                FTabEntry(
                  label: Text(l10n.authAccountOverviewTitle),
                  child: FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.level6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AccountStatusSection(
                            user: user,
                            l10n: l10n,
                            onVerifyEmail: () => _verifyEmailFlow(
                              context,
                              l10n,
                              ref,
                              user.email!,
                            ),
                          ),
                          const SizedBox(height: Spacing.level6),
                          _ProfileSection(
                            nicknameController: nicknameController,
                            avatarController: avatarController,
                            isSubmitting: accountState.isSubmitting,
                            onSave: () async {
                              final ok = await accountNotifier.updateProfile(
                                nickname: nicknameController.text,
                                avatar: avatarController.text,
                              );
                              if (ok && context.mounted) {
                                await Toast.show(
                                  context,
                                  l10n.authProfileSaveSuccess,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: Spacing.level6),
                          EmailSection(
                            user: user,
                            emailController: emailController,
                            onChangeEmail: () =>
                                context.push(Routes.accountChangeEmail),
                          ),
                          const SizedBox(height: Spacing.level6),
                          LinkedIdentitiesSection(
                            user: user,
                            isSubmitting: accountState.isSubmitting,
                            onLinkWechat: () =>
                                _startWechatIdentityLink(context, l10n, ref),
                            onUnlink: (identity) async {
                              final confirmed = await _confirmUnlinkIdentity(
                                context,
                                identity,
                                l10n,
                              );
                              if (!confirmed || !context.mounted) return;
                              final ok = await accountNotifier.unlinkIdentity(
                                identityId: identity.id,
                              );
                              if (ok && context.mounted) {
                                await Toast.show(
                                  context,
                                  l10n.authIdentityUnlinkSuccess,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FTabEntry(
                  label: Text(l10n.authPasswordSectionTitle),
                  child: FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.level6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PasswordSection(
                            user: user,
                            oldPasswordController: oldPasswordController,
                            newPasswordController: newPasswordController,
                            isSubmitting: accountState.isSubmitting,
                            onChangePassword: () async {
                              final ctx = context;
                              final router = GoRouter.of(ctx);
                              final ok = await accountNotifier.changePassword(
                                oldPassword: oldPasswordController.text,
                                newPassword: newPasswordController.text,
                              );
                              if (!ok && ctx.mounted) {
                                final msg =
                                    accountState.errorMessage?.isNotEmpty ==
                                        true
                                    ? accountState.errorMessage!
                                    : null;
                                if (msg != null) {
                                  await Toast.show(ctx, msg);
                                }
                                return;
                              }
                              if (!ok || !ctx.mounted) return;
                              await Toast.show(
                                ctx,
                                l10n.authChangePasswordSuccess,
                              );
                              if (ctx.mounted) router.go(Routes.login);
                            },
                          ),
                          const SizedBox(height: Spacing.level6),
                          DeleteAccountSection(
                            user: user,
                            deletePasswordController: deletePasswordController,
                            deleteCodeController: deleteCodeController,
                            isSubmitting: accountState.isSubmitting,
                            isSendingCode: accountState.isSendingCode,
                            cooldownSeconds: accountState.lastCooldownSeconds,
                            onSendCode: () async {
                              if (user.email == null ||
                                  user.email!.trim().isEmpty) {
                                await Toast.show(
                                  context,
                                  l10n.authDeleteAccountEmailRequiredHint,
                                );
                                return;
                              }
                              await accountNotifier.sendVerificationCode(
                                email: user.email!,
                                scene: AuthVerificationScene.deleteAccount,
                              );
                            },
                            onDelete: () async {
                              final ctx = context;
                              final router = GoRouter.of(ctx);
                              if (user.hasPassword) {
                                final ok = await accountNotifier.deleteAccount(
                                  password: deletePasswordController.text,
                                );
                                if (!ok && ctx.mounted) {
                                  final msg =
                                      accountState.errorMessage?.isNotEmpty ==
                                          true
                                      ? accountState.errorMessage!
                                      : null;
                                  if (msg != null) {
                                    await Toast.show(ctx, msg);
                                  }
                                  return;
                                }
                                if (!ok || !ctx.mounted) return;
                                await Toast.show(
                                  ctx,
                                  l10n.authDeleteAccountSuccess,
                                );
                                if (ctx.mounted) router.go(Routes.login);
                              } else {
                                final ok = await accountNotifier.deleteAccount(
                                  code: deleteCodeController.text,
                                );
                                if (!ok && ctx.mounted) {
                                  final msg =
                                      accountState.errorMessage?.isNotEmpty ==
                                          true
                                      ? accountState.errorMessage!
                                      : null;
                                  if (msg != null) {
                                    await Toast.show(ctx, msg);
                                  }
                                  return;
                                }
                                if (!ok || !ctx.mounted) return;
                                await Toast.show(
                                  ctx,
                                  l10n.authDeleteAccountSuccess,
                                );
                                if (ctx.mounted) router.go(Routes.login);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _startWechatIdentityLink(
  BuildContext context,
  AppLocalizations l10n,
  WidgetRef ref,
) async {
  final result = await ref
      .read(authAccountProvider.notifier)
      .startWechatIdentityLink(webCallbackUri: _webWechatLinkCallbackUri());
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

String? _webWechatLinkCallbackUri() {
  if (!kIsWeb) return null;
  final base = Uri.base;
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: '/account/oauth/wechat',
  ).toString();
}

Future<bool> _confirmUnlinkIdentity(
  BuildContext context,
  AuthLinkedIdentity identity,
  AppLocalizations l10n,
) async {
  final result = await showAppDialog<bool>(
    context: context,
    maxWidth: LayoutScaleResolver.wideDialogMaxWidth,
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

Future<void> _verifyEmailFlow(
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

  final code = await _showVerifyEmailDialog(context, l10n);
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

Future<String?> _showVerifyEmailDialog(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final controller = TextEditingController();
  final result = await showAppDialog<String>(
    context: context,
    maxWidth: LayoutScaleResolver.wideDialogMaxWidth,
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

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
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
                                const Icon(FLucideIcons.userRound, size: 28),
                          ),
                        )
                      : const Icon(FLucideIcons.userRound, size: 28),
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
