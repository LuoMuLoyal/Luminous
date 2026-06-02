import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/auth_account_provider.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key, this.enableFormAnimation = true});

  final bool enableFormAnimation;

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _avatarController;
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _deletePasswordController;

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
    final signedOut = !session.isAuthenticated || user == null;
    final success = accountState.successMessage?.isNotEmpty == true
        ? accountState.successMessage
        : null;

    return AuthShell(
      badge: l10n.authAccountSettingsBadge,
      title: l10n.authAccountSettingsTitle,
      description: l10n.authAccountSettingsDescription,
      enableFormAnimation: widget.enableFormAnimation,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthFormHeader(
            title: l10n.authAccountSettingsFormTitle,
            description: signedOut
                ? l10n.authAccountSettingsSignedOutLead
                : l10n.authSignedInAs(user.email),
          ),
          const SizedBox(height: AppSpacingTokens.xl),
          if (signedOut) ...[
            AuthStatusMessage(error: l10n.authNotSignedIn),
            const SizedBox(height: AppSpacingTokens.lg),
            AuthPrimaryButton(
              label: l10n.authGoLogin,
              onPressed: () => context.go('/login'),
            ),
          ] else ...[
            AuthSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.authProfileSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    l10n.authProfileSectionDescription,
                    style: Theme.of(context).textTheme.bodySmall,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.authEmailSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    user.emailVerified
                        ? l10n.authEmailVerifiedDescription
                        : l10n.authEmailUnverifiedDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  AuthTextField(
                    controller: _emailController,
                    label: l10n.authEmailLabel,
                    enabled: false,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  AuthPrimaryButton(
                    label: l10n.authEmailChangeAction,
                    onPressed: () => context.push('/account/change-email'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.authPasswordSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    l10n.authPasswordSectionDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  AuthTextField(
                    controller: _oldPasswordController,
                    label: l10n.authCurrentPasswordLabel,
                    hint: l10n.authPasswordHint,
                    obscureText: true,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  AuthTextField(
                    controller: _newPasswordController,
                    label: l10n.authNewPasswordLabel,
                    hint: l10n.authPasswordHint,
                    obscureText: true,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  AuthPrimaryButton(
                    label: l10n.authChangePasswordAction,
                    isLoading: accountState.isSubmitting,
                    onPressed: () async {
                      final currentContext = context;
                      final router = GoRouter.of(currentContext);
                      if (_oldPasswordController.text.trim().isEmpty) {
                        await AppToast.show(
                          currentContext,
                          l10n.authCurrentPasswordRequiredToast,
                        );
                        return;
                      }
                      if (_newPasswordController.text.trim().isEmpty) {
                        await AppToast.show(
                          currentContext,
                          l10n.authNewPasswordRequiredToast,
                        );
                        return;
                      }
                      final ok = await accountNotifier.changePassword(
                        oldPassword: _oldPasswordController.text,
                        newPassword: _newPasswordController.text,
                      );
                      if (!ok || !currentContext.mounted) {
                        return;
                      }
                      await AppToast.show(
                        currentContext,
                        l10n.authChangePasswordSuccess,
                      );
                      if (!currentContext.mounted) {
                        return;
                      }
                      router.go('/login');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            AuthSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.authDeleteAccountSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    l10n.authDeleteAccountSectionDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacingTokens.lg),
                  AuthTextField(
                    controller: _deletePasswordController,
                    label: l10n.authCurrentPasswordLabel,
                    hint: l10n.authDeleteAccountHint,
                    obscureText: true,
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  AuthPrimaryButton(
                    label: l10n.authDeleteAccountAction,
                    isLoading: accountState.isSubmitting,
                    onPressed: () async {
                      final currentContext = context;
                      final router = GoRouter.of(currentContext);
                      if (_deletePasswordController.text.trim().isEmpty) {
                        await AppToast.show(
                          currentContext,
                          l10n.authCurrentPasswordRequiredToast,
                        );
                        return;
                      }
                      final ok = await accountNotifier.deleteAccount(
                        password: _deletePasswordController.text,
                      );
                      if (!ok || !currentContext.mounted) {
                        return;
                      }
                      await AppToast.show(
                        currentContext,
                        l10n.authDeleteAccountSuccess,
                      );
                      if (!currentContext.mounted) {
                        return;
                      }
                      router.go('/login');
                    },
                  ),
                ],
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
}
