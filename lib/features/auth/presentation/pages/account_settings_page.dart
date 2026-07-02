import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/core/widgets/common/app_dialog.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_sections.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_account_provider.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
    final success = accountState.successMessage?.isNotEmpty == true
        ? accountState.successMessage
        : null;

    final emailController = useTextEditingController(text: user?.email ?? '');
    final nicknameController = useTextEditingController(
      text: user?.nickname ?? '',
    );
    final avatarController = useTextEditingController(text: user?.avatar ?? '');
    final oldPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final deletePasswordController = useTextEditingController();
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
        await AppToast.show(context, l10n.authIdentityLinkSuccess);
        if (context.mounted) context.go('/account');
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
                  child: FCard.raw(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacingTokens.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AccountStatusSection(user: user, l10n: l10n),
                          const SizedBox(height: AppSpacingTokens.xl),
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
                                await AppToast.show(
                                  context,
                                  l10n.authProfileSaveSuccess,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacingTokens.xl),
                          EmailSection(
                            user: user,
                            emailController: emailController,
                            onChangeEmail: () =>
                                context.push('/account/change-email'),
                          ),
                          const SizedBox(height: AppSpacingTokens.xl),
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
                                await AppToast.show(
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
                  child: FCard.raw(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacingTokens.xl),
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
                              if (oldPasswordController.text.trim().isEmpty) {
                                await AppToast.show(
                                  ctx,
                                  l10n.authCurrentPasswordRequiredToast,
                                );
                                return;
                              }
                              if (newPasswordController.text.trim().isEmpty) {
                                await AppToast.show(
                                  ctx,
                                  l10n.authNewPasswordRequiredToast,
                                );
                                return;
                              }
                              final ok = await accountNotifier.changePassword(
                                oldPassword: oldPasswordController.text,
                                newPassword: newPasswordController.text,
                              );
                              if (!ok || !ctx.mounted) return;
                              await AppToast.show(
                                ctx,
                                l10n.authChangePasswordSuccess,
                              );
                              if (ctx.mounted) router.go('/login');
                            },
                          ),
                          const SizedBox(height: AppSpacingTokens.xl),
                          DeleteAccountSection(
                            user: user,
                            deletePasswordController: deletePasswordController,
                            isSubmitting: accountState.isSubmitting,
                            onDelete: () async {
                              final ctx = context;
                              final router = GoRouter.of(ctx);
                              if (deletePasswordController.text
                                  .trim()
                                  .isEmpty) {
                                await AppToast.show(
                                  ctx,
                                  l10n.authCurrentPasswordRequiredToast,
                                );
                                return;
                              }
                              final ok = await accountNotifier.deleteAccount(
                                password: deletePasswordController.text,
                              );
                              if (!ok || !ctx.mounted) return;
                              await AppToast.show(
                                ctx,
                                l10n.authDeleteAccountSuccess,
                              );
                              if (ctx.mounted) router.go('/login');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if ((accountState.errorMessage?.isNotEmpty ?? false) ||
                success != null) ...[
              const SizedBox(height: AppSpacingTokens.md),
              FToast(
                variant: accountState.errorMessage?.isNotEmpty == true
                    ? FToastVariant.destructive
                    : FToastVariant.primary,
                title: Text(
                  accountState.errorMessage?.isNotEmpty == true
                      ? accountState.errorMessage!
                      : success!,
                ),
              ),
            ],
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
      await AppToast.show(context, l10n.authIdentityLinkSuccess);
    case WechatIdentityLinkResult.opened:
      await AppToast.show(context, l10n.authWechatAuthorizeOpened);
    case WechatIdentityLinkResult.unsupported:
      await AppToast.show(context, l10n.authIdentityLinkUnsupported);
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
  final result = await showFDialog<bool>(
    context: context,
    builder: (context, style, animation) => AppDialog(
      maxWidth: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.authIdentityUnlinkConfirmTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Text(
            l10n.authIdentityUnlinkConfirmMessage(
              identityProviderLabel(identity.provider, l10n),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacingTokens.xl),
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
              const SizedBox(width: AppSpacingTokens.sm),
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
    ),
  );
  return result ?? false;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authProfileSectionTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        FTextField(
          control: FTextFieldControl.managed(controller: nicknameController),
          label: Text(l10n.authNicknameLabel),
          hint: l10n.authNicknameHint,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        FTextField(
          control: FTextFieldControl.managed(controller: avatarController),
          label: Text(l10n.authAvatarLabel),
          hint: l10n.authAvatarHint,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        SizedBox(
          width: double.infinity,
          child: FButton(
            onPress: isSubmitting ? null : () => onSave(),
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.authProfileSaveAction),
          ),
        ),
      ],
    );
  }
}
