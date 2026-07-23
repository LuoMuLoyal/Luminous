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
import 'package:luminous/features/auth/presentation/widgets/shared/verification_code_field.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return AuthShell(
      title: l10n.authResetPasswordAction,
      subtitle: l10n.authForgotPasswordSubtitle,
      logo: const AuthBrandLogo(),
      leading: const AppBackButton(fallbackRoute: Routes.home),
      centerTitle: true,
      form: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FTextFormField.email(
              control: FTextFieldControl.managed(controller: emailController),
              label: Text(l10n.authEmailLabel),
              hint: l10n.authEmailHint,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => EmailInput.validate(
                value,
                requiredMessage: l10n.authEmailRequiredError,
                invalidMessage: l10n.authEmailInvalidError,
              ),
            ),
            const SizedBox(height: Spacing.level4),
            VerificationCodeField(
              controller: codeController,
              label: l10n.authCodeLabel,
              hint: l10n.authCodeLabel,
              buttonLabel: state.cooldownSeconds == null
                  ? l10n.authSendCode
                  : l10n.authSendCodeAgain(state.cooldownSeconds!),
              isLoading: state.isSendingCode,
              validator: (value) =>
                  RequiredInput.validate(value, l10n.authCodeRequiredError),
              onSendCode:
                  (state.cooldownSeconds != null && state.cooldownSeconds! > 0)
                  ? null
                  : () async {
                      final emailError = EmailInput.validate(
                        emailController.text,
                        requiredMessage: l10n.authEmailRequiredError,
                        invalidMessage: l10n.authEmailInvalidError,
                      );
                      if (emailError != null) {
                        formKey.currentState?.validate();
                        return;
                      }
                      notifier.updateEmail(emailController.text);
                      final ok = await notifier.sendResetCode();
                      if (!ok && context.mounted) {
                        final msg = ref
                            .read(passwordResetProvider)
                            .errorMessage;
                        if (msg != null && msg.isNotEmpty) {
                          await Toast.show(context, msg);
                        }
                      }
                    },
            ),
            const SizedBox(height: Spacing.level4),
            FTextFormField.password(
              control: FTextFieldControl.managed(
                controller: passwordController,
              ),
              label: Text(l10n.authNewPasswordLabel),
              hint: l10n.authPasswordHint,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  RequiredInput.validate(value, l10n.authPasswordRequiredError),
            ),
            const SizedBox(height: Spacing.level4),
            FTextFormField.password(
              control: FTextFieldControl.managed(
                controller: confirmPasswordController,
              ),
              label: Text(l10n.authConfirmPasswordLabel),
              hint: l10n.authPasswordHint,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                final requiredError = RequiredInput.validate(
                  value,
                  l10n.authConfirmPasswordRequiredError,
                );
                if (requiredError != null) {
                  return requiredError;
                }
                if ((value ?? '') != passwordController.text) {
                  return l10n.authPasswordsDoNotMatchError;
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.level6),
            SizedBox(
              width: double.infinity,
              child: FButton(
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
                        if (!ok && context.mounted) {
                          final msg =
                              ref
                                      .read(passwordResetProvider)
                                      .errorMessage
                                      ?.isNotEmpty ==
                                  true
                              ? ref.read(passwordResetProvider).errorMessage!
                              : null;
                          if (msg != null) {
                            await Toast.show(context, msg);
                          }
                        }
                        if (ok && context.mounted) {
                          await Toast.show(
                            context,
                            l10n.authResetPasswordSuccess,
                          );
                        }
                      },
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: FCircularProgress(),
                      )
                    : Text(l10n.authResetPasswordAction),
              ),
            ),
            const SizedBox(height: Spacing.level3),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Spacing.level2,
              runSpacing: Spacing.level1,
              children: [
                Text(
                  l10n.authRememberPasswordPrompt,
                  style: TypographyToken.level2
                      .body(context)
                      .copyWith(color: context.theme.colors.mutedForeground),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => context.push(Routes.login),
                  child: Text(
                    l10n.authSignIn,
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
