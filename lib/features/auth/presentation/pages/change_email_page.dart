import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_account_provider.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ChangeEmailPage extends HookConsumerWidget {
  const ChangeEmailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final codeController = useTextEditingController();

    final accountState = ref.watch(authAccountProvider);
    final accountNotifier = ref.read(authAccountProvider.notifier);
    final session = ref.watch(authSessionProvider);
    final l10n = AppLocalizations.of(context);
    final isSignedIn = session.canAccessProtectedData && session.user != null;
    final success = accountState.successMessage?.isNotEmpty == true
        ? accountState.successMessage
        : null;

    bool validateSubmit() {
      final message = switch ((
        emailController.text.trim().isEmpty,
        codeController.text.trim().isEmpty,
      )) {
        (true, _) => l10n?.authEmailRequiredToast ?? 'Please enter your email.',
        (_, true) =>
          l10n?.authCodeRequiredToast ?? 'Please enter the verification code.',
        _ => null,
      };
      if (message == null) {
        return true;
      }
      AppToast.show(context, message);
      return false;
    }

    return AuthShell(
      title: l10n?.authChangeEmailFormTitle ?? 'Change email',
      leading: BackButton(onPressed: () => context.pop()),
      centerTitle: true,
      form: session.isLoading
          ? const _ChangeEmailLoading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthTextField(
                  controller: emailController,
                  label: l10n?.authNewEmailLabel ?? 'New email',
                  hint: l10n?.authEmailHint ?? 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacingTokens.md),
                AuthCodeFieldRow(
                  controller: codeController,
                  label: l10n?.authCodeLabel ?? 'Verification code',
                  buttonLabel: accountState.lastCooldownSeconds == null
                      ? l10n?.authSendCode ?? 'Send code'
                      : l10n?.authSendCodeAgain(
                              accountState.lastCooldownSeconds!,
                            ) ??
                            'Send again (${accountState.lastCooldownSeconds}s)',
                  isLoading: accountState.isSendingCode,
                  onSendCode: !isSignedIn
                      ? null
                      : () async {
                          if (emailController.text.trim().isEmpty) {
                            await AppToast.show(
                              context,
                              l10n?.authEmailRequiredToast ??
                                  'Please enter your email.',
                            );
                            return;
                          }
                          await accountNotifier.sendVerificationCode(
                            email: emailController.text,
                            scene: AuthVerificationScene.changeEmail,
                          );
                        },
                ),
                if ((accountState.errorMessage?.isNotEmpty ?? false) ||
                    success != null) ...[
                  const SizedBox(height: AppSpacingTokens.md),
                  AuthStatusMessage(
                    error: accountState.errorMessage,
                    success: success,
                  ),
                ],
                const SizedBox(height: AppSpacingTokens.xl),
                AuthPrimaryButton(
                  label: l10n?.authChangeEmailSubmit ?? 'Update email',
                  isLoading: accountState.isSubmitting,
                  onPressed: !isSignedIn
                      ? null
                      : () async {
                          if (!validateSubmit()) {
                            return;
                          }
                          final ok = await accountNotifier.changeEmail(
                            newEmail: emailController.text,
                            code: codeController.text,
                          );
                          if (ok && context.mounted) {
                            await AppToast.show(
                              context,
                              l10n?.authChangeEmailSuccess ?? 'Email updated.',
                            );
                          }
                        },
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                AuthFooterAction(
                  prompt: !isSignedIn
                      ? l10n?.authNotSignedIn ?? 'Not signed in yet.'
                      : l10n?.authBackHomePrompt ?? 'Back to home?',
                  actionLabel: !isSignedIn
                      ? l10n?.authSignIn ?? 'Sign in'
                      : l10n?.todayHeroTitle ?? 'Today',
                  onPressed: () => context.push(!isSignedIn ? '/login' : '/'),
                ),
              ],
            ),
    );
  }
}

class _ChangeEmailLoading extends StatelessWidget {
  const _ChangeEmailLoading();

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeleton(
      children: [
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
      ],
    );
  }
}
