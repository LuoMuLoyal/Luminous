import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/forms/register_form_provider.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final codeController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final nicknameController = useTextEditingController();

    final state = ref.watch(registerFormProvider);
    final notifier = ref.read(registerFormProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return AuthShell(
      title: l10n?.authCreateAccountAction ?? 'Create account',
      subtitle: l10n?.authRegisterSubtitle,
      logo: const AuthBrandLogo(),
      leading: const AppBackButton(fallbackRoute: '/'),
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
                controller: emailController,
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
                controller: codeController,
                label: l10n?.authCodeLabel ?? 'Verification code',
                buttonLabel: state.cooldownSeconds == null
                    ? l10n?.authSendCode ?? 'Send code'
                    : l10n?.authSendCodeAgain(state.cooldownSeconds!) ??
                          'Send again (${state.cooldownSeconds}s)',
                isLoading: state.isSendingCode,
                onSendCode: () async {
                  notifier.updateEmail(emailController.text);
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
                  await notifier.sendCode();
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
                controller: passwordController,
                label: l10n?.authPasswordLabel ?? 'Password',
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
                controller: confirmPasswordController,
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
          const SizedBox(height: AppSpacingTokens.md),
          AuthTextField(
            controller: nicknameController,
            label: l10n?.authNicknameLabel ?? 'Nickname',
            hint: l10n?.authNicknameHint ?? 'Optional',
            prefix: const Icon(Icons.person_outline),
          ),
          if ((state.errorMessage?.isNotEmpty ?? false) ||
              (state.successMessage?.isNotEmpty ?? false)) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AuthStatusMessage(
              error: state.errorMessage,
              success: state.successMessage,
            ),
          ],
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            label: l10n?.authCreateAccountAction ?? 'Create account',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(emailController.text);
              notifier.updateCode(codeController.text);
              notifier.updatePassword(passwordController.text);
              notifier.updateConfirmPassword(confirmPasswordController.text);
              notifier.updateNickname(nicknameController.text);
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
              final ok = await notifier.submit();
              if (ok && context.mounted) {
                await AppToast.show(
                  context,
                  l10n?.authRegisterSuccess ??
                      'Account created. Please sign in.',
                );
                if (!context.mounted) {
                  return;
                }
                context.go('/login');
              }
            },
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          AuthTermsNotice(
            onTerms: () => AppToast.show(
              context,
              l10n?.authTermsComingSoonToast ??
                  'Terms and privacy policy will be available soon.',
            ),
            onPrivacy: () => AppToast.show(
              context,
              l10n?.authTermsComingSoonToast ??
                  'Terms and privacy policy will be available soon.',
            ),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          AuthFooterAction(
            prompt: l10n?.authHaveAccountPrompt ?? 'Already have an account?',
            actionLabel: l10n?.authSignIn ?? 'Sign in',
            onPressed: () => context.push('/login'),
          ),
        ],
      ),
    );
  }
}
