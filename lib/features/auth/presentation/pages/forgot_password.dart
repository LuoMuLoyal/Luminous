import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/features/auth/presentation/providers/forms/password_reset.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final codeController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

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
      leading: const AppBackButton(fallbackRoute: AppRoutes.home),
      centerTitle: true,
      form: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FTextFormField.email(
              control: FTextFieldControl.managed(controller: emailController),
              label: Text(l10n?.authEmailLabel ?? 'Email'),
              hint: l10n?.authEmailHint ?? 'name@example.com',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => EmailInput.validate(
                value,
                requiredMessage:
                    l10n?.authEmailRequiredError ?? 'Please enter your email.',
                invalidMessage:
                    l10n?.authEmailInvalidError ??
                    'Please enter a valid email address.',
              ),
            ),
            const SizedBox(height: Spacing.level4),
            VerificationCodeField(
              controller: codeController,
              label: l10n?.authCodeLabel ?? 'Verification code',
              hint: l10n?.authCodeLabel ?? 'Verification code',
              buttonLabel: state.cooldownSeconds == null
                  ? l10n?.authSendCode ?? 'Send code'
                  : l10n?.authSendCodeAgain(state.cooldownSeconds!) ??
                        'Send again (${state.cooldownSeconds}s)',
              isLoading: state.isSendingCode,
              validator: (value) => RequiredInput.validate(
                value,
                l10n?.authCodeRequiredError ??
                    'Please enter the verification code.',
              ),
              onSendCode: () async {
                final emailError = EmailInput.validate(
                  emailController.text,
                  requiredMessage:
                      l10n?.authEmailRequiredError ??
                      'Please enter your email.',
                  invalidMessage:
                      l10n?.authEmailInvalidError ??
                      'Please enter a valid email address.',
                );
                if (emailError != null) {
                  formKey.currentState?.validate();
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
                notifier.updateEmail(emailController.text);
                await notifier.sendResetCode();
              },
            ),
            const SizedBox(height: Spacing.level4),
            FTextFormField.password(
              control: FTextFieldControl.managed(
                controller: passwordController,
              ),
              label: Text(l10n?.authNewPasswordLabel ?? 'New password'),
              hint:
                  l10n?.authPasswordHint ??
                  'At least 8 characters, ideally with mixed case and numbers',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => RequiredInput.validate(
                value,
                l10n?.authPasswordRequiredError ??
                    'Please enter your password.',
              ),
            ),
            const SizedBox(height: Spacing.level4),
            FTextFormField.password(
              control: FTextFieldControl.managed(
                controller: confirmPasswordController,
              ),
              label: Text(l10n?.authConfirmPasswordLabel ?? 'Confirm password'),
              hint:
                  l10n?.authPasswordHint ??
                  'At least 8 characters, ideally with mixed case and numbers',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                final requiredError = RequiredInput.validate(
                  value,
                  l10n?.authConfirmPasswordRequiredError ??
                      'Please confirm your password.',
                );
                if (requiredError != null) {
                  return requiredError;
                }
                if ((value ?? '') != passwordController.text) {
                  return l10n?.authPasswordsDoNotMatchError ??
                      'Passwords do not match.';
                }
                return null;
              },
            ),
            if ((state.errorMessage?.isNotEmpty ?? false) ||
                success != null) ...[
              const SizedBox(height: Spacing.level4),
              FToast(
                variant: state.errorMessage?.isNotEmpty == true
                    ? FToastVariant.destructive
                    : FToastVariant.primary,
                title: Text(
                  state.errorMessage?.isNotEmpty == true
                      ? state.errorMessage!
                      : success!,
                ),
              ),
            ],
            const SizedBox(height: Spacing.level6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: state.isSubmitting
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          notifier.updateEmail(emailController.text);
                          notifier.updateCode(codeController.text);
                          notifier.updatePassword(passwordController.text);
                          notifier.updateConfirmPassword(
                            confirmPasswordController.text,
                          );
                          final ok = await notifier.resetPassword();
                          if (ok && context.mounted) {
                            await AppToast.show(
                              context,
                              l10n?.authResetPasswordSuccess ??
                                  'Password updated. Please sign in again.',
                            );
                          }
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: FCircularProgress(),
                        )
                      : Text(l10n?.authResetPasswordAction ?? 'Reset password'),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level3),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Spacing.level2,
              runSpacing: Spacing.level1,
              children: [
                Text(
                  l10n?.authRememberPasswordPrompt ?? 'Remember your password?',
                  style: TypographyToken.level2
                      .body(context)
                      .copyWith(color: context.theme.colors.mutedForeground),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => context.push(AppRoutes.login),
                  child: Text(
                    l10n?.authSignIn ?? 'Sign in',
                    style: TypographyToken.level2.body(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
