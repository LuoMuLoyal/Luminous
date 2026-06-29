import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_sections.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_account_provider.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
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
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  late final TextEditingController _emailController,
      _nicknameController,
      _avatarController;
  late final TextEditingController _oldPasswordController,
      _newPasswordController,
      _deletePasswordController;
  String? _formUserId;
  bool _wechatIdentityLinkStarted = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authSessionProvider).user;
    _emailController = TextEditingController(text: user?.email ?? '');
    _nicknameController = TextEditingController(text: user?.nickname ?? '');
    _avatarController = TextEditingController(text: user?.avatar ?? '');
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _deletePasswordController = TextEditingController();
    _formUserId = user?.id;
    if ((widget.wechatCode?.isNotEmpty ?? false) &&
        (widget.wechatState?.isNotEmpty ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeCompleteWechatIdentityLink();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _avatarController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    _syncControllersFromUser(user);

    if ((widget.wechatCode?.isNotEmpty ?? false) &&
        (widget.wechatState?.isNotEmpty ?? false) &&
        !_wechatIdentityLinkStarted &&
        !session.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeCompleteWechatIdentityLink();
      });
    }

    return AuthShell(
      title: l10n.authAccountSettingsFormTitle,
      leading: BackButton(onPressed: () => context.pop()),
      centerTitle: true,
      enableFormAnimation: widget.enableFormAnimation,
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
            AuthSectionCard(
              child: AccountStatusSection(user: user, l10n: l10n),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.authProfileSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  AuthTextField(
                    controller: _nicknameController,
                    label: l10n.authNicknameLabel,
                    hint: l10n.authNicknameHint,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  AuthTextField(
                    controller: _avatarController,
                    label: l10n.authAvatarLabel,
                    hint: l10n.authAvatarHint,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  AuthPrimaryButton(
                    label: l10n.authProfileSaveAction,
                    isLoading: accountState.isSubmitting,
                    onPressed: () async {
                      final ok = await accountNotifier.updateProfile(
                        nickname: _nicknameController.text,
                        avatar: _avatarController.text,
                      );
                      if (ok && context.mounted) {
                        await AppToast.show(
                          context,
                          l10n.authProfileSaveSuccess,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: EmailSection(
                user: user,
                emailController: _emailController,
                onChangeEmail: () => context.push('/account/change-email'),
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: LinkedIdentitiesSection(
                user: user,
                isSubmitting: accountState.isSubmitting,
                onLinkWechat: () => _startWechatIdentityLink(context, l10n),
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
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: PasswordSection(
                user: user,
                oldPasswordController: _oldPasswordController,
                newPasswordController: _newPasswordController,
                isSubmitting: accountState.isSubmitting,
                onChangePassword: () async {
                  final ctx = context;
                  final router = GoRouter.of(ctx);
                  if (_oldPasswordController.text.trim().isEmpty) {
                    await AppToast.show(
                      ctx,
                      l10n.authCurrentPasswordRequiredToast,
                    );
                    return;
                  }
                  if (_newPasswordController.text.trim().isEmpty) {
                    await AppToast.show(ctx, l10n.authNewPasswordRequiredToast);
                    return;
                  }
                  final ok = await accountNotifier.changePassword(
                    oldPassword: _oldPasswordController.text,
                    newPassword: _newPasswordController.text,
                  );
                  if (!ok || !ctx.mounted) return;
                  await AppToast.show(ctx, l10n.authChangePasswordSuccess);
                  if (ctx.mounted) router.go('/login');
                },
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: DeleteAccountSection(
                user: user,
                deletePasswordController: _deletePasswordController,
                isSubmitting: accountState.isSubmitting,
                onDelete: () async {
                  final ctx = context;
                  final router = GoRouter.of(ctx);
                  if (_deletePasswordController.text.trim().isEmpty) {
                    await AppToast.show(
                      ctx,
                      l10n.authCurrentPasswordRequiredToast,
                    );
                    return;
                  }
                  final ok = await accountNotifier.deleteAccount(
                    password: _deletePasswordController.text,
                  );
                  if (!ok || !ctx.mounted) return;
                  await AppToast.show(ctx, l10n.authDeleteAccountSuccess);
                  if (ctx.mounted) router.go('/login');
                },
              ),
            ),
            if ((accountState.errorMessage?.isNotEmpty ?? false) ||
                success != null) ...[
              const SizedBox(height: AppSpacingTokens.md),
              AuthStatusMessage(
                error: accountState.errorMessage,
                success: success,
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _syncControllersFromUser(AuthUser? user) {
    if (user == null || _formUserId == user.id) return;
    _formUserId = user.id;
    _emailController.text = user.email ?? '';
    _nicknameController.text = user.nickname ?? '';
    _avatarController.text = user.avatar ?? '';
  }

  void _maybeCompleteWechatIdentityLink() {
    if (_wechatIdentityLinkStarted ||
        widget.wechatCode?.isNotEmpty != true ||
        widget.wechatState?.isNotEmpty != true) {
      return;
    }
    final session = ref.read(authSessionProvider);
    if (session.isLoading) return;
    _wechatIdentityLinkStarted = true;
    if (!session.canAccessProtectedData) {
      context.go(loginRouteForReturnTo('/account'));
      return;
    }
    unawaited(
      _completeWechatIdentityLink(widget.wechatCode!, widget.wechatState!),
    );
  }

  Future<void> _completeWechatIdentityLink(String code, String state) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await ref
        .read(authAccountProvider.notifier)
        .completeWechatWebIdentityLink(code: code, state: state);
    if (!mounted) return;
    if (ok) {
      await AppToast.show(context, l10n.authIdentityLinkSuccess);
      if (mounted) context.go('/account');
    }
  }
}

Future<void> _startWechatIdentityLink(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final result = await container
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
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.authIdentityUnlinkConfirmTitle),
      content: Text(
        l10n.authIdentityUnlinkConfirmMessage(
          identityProviderLabel(identity.provider, l10n),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.authCancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.authIdentityUnlinkAction),
        ),
      ],
    ),
  );
  return result ?? false;
}
