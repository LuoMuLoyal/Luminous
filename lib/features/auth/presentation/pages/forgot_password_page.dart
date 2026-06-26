import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/password_reset_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _codeController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final success = state.successMessage?.isNotEmpty == true
        ? state.successMessage
        : null;

    return AuthShell(
      title: l10n?.authResetPasswordAction ?? 'Reset password',
      subtitle: l10n?.authForgotPasswordSubtitle,
      logo: const AuthBrandLogo(),
      leading: const AuthBackButton(),
      centerTitle: true,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthTextField(
                controller: _emailController,
                label: l10n?.authEmailLabel ?? 'Email',
                hint: l10n?.authEmailHint ?? 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(Icons.mail_outline),
              ),
              AuthFieldError(state.emailError),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthCodeFieldRow(
                controller: _codeController,
                label: l10n?.authCodeLabel ?? 'Verification code',
                buttonLabel: state.cooldownSeconds == null
                    ? l10n?.authSendCode ?? 'Send code'
                    : l10n?.authSendCodeAgain(state.cooldownSeconds!) ??
                          'Send again (${state.cooldownSeconds}s)',
                isLoading: state.isSendingCode,
                onSendCode: () async {
                  notifier.updateEmail(_emailController.text);
                  if (!notifier.validateEmailOnly(
                    emailRequired:
                        l10n?.authEmailRequiredError ??
                        'Please enter your email.',
                  )) {
                    return;
                  }
                  if (state.cooldownSeconds != null &&
                      state.cooldownSeconds! > 0) {
                    await AppToast.show(
                      context,
                      l10n?.authCodeResendWait(state.cooldownSeconds!) ??
                          'Please wait ${state.cooldownSeconds}s before resending.',
                    );
                    return;
                  }
                  await notifier.sendResetCode();
                },
              ),
              AuthFieldError(state.codeError),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthTextField(
                controller: _passwordController,
                label: l10n?.authNewPasswordLabel ?? 'New password',
                hint:
                    l10n?.authPasswordHint ??
                    'At least 8 characters, ideally with mixed case and numbers',
                obscureText: true,
                prefix: const Icon(Icons.lock_outline),
              ),
              AuthFieldError(state.passwordError),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthTextField(
                controller: _confirmPasswordController,
                label: l10n?.authConfirmPasswordLabel ?? 'Confirm password',
                hint:
                    l10n?.authPasswordHint ??
                    'At least 8 characters, ideally with mixed case and numbers',
                obscureText: true,
                prefix: const Icon(Icons.lock_outline),
              ),
              AuthFieldError(state.confirmPasswordError),
            ],
          ),
          if ((state.errorMessage?.isNotEmpty ?? false) || success != null) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AuthStatusMessage(error: state.errorMessage, success: success),
          ],
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            label: l10n?.authResetPasswordAction ?? 'Reset password',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(_emailController.text);
              notifier.updateCode(_codeController.text);
              notifier.updatePassword(_passwordController.text);
              notifier.updateConfirmPassword(_confirmPasswordController.text);
              final isValid = notifier.validate(
                emailRequired:
                    l10n?.authEmailRequiredError ?? 'Please enter your email.',
                emailInvalid:
                    l10n?.authEmailInvalidError ??
                    'Please enter a valid email address.',
                codeRequired:
                    l10n?.authCodeRequiredError ??
                    'Please enter the verification code.',
                passwordRequired:
                    l10n?.authPasswordRequiredError ??
                    'Please enter your password.',
                confirmPasswordRequired:
                    l10n?.authConfirmPasswordRequiredError ??
                    'Please confirm your password.',
                passwordsDoNotMatch:
                    l10n?.authPasswordsDoNotMatchError ??
                    'Passwords do not match.',
              );
              if (!isValid) {
                return;
              }
              final ok = await notifier.resetPassword();
              if (ok && context.mounted) {
                await AppToast.show(
                  context,
                  l10n?.authResetPasswordSuccess ??
                      'Password updated. Please sign in again.',
                );
              }
            },
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          AuthFooterAction(
            prompt:
                l10n?.authRememberPasswordPrompt ?? 'Remember your password?',
            actionLabel: l10n?.authSignIn ?? 'Sign in',
            onPressed: () => context.push('/login'),
          ),
        ],
      ),
    );
  }
}
