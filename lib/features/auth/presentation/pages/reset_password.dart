import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/widgets/common/control/back_button.dart';
import 'package:luminous/features/auth/presentation/providers/forms/password_reset.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/branding.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ResetPasswordPage extends HookConsumerWidget {
  const ResetPasswordPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // S-1: Guard against empty/missing token — the deep link may have been
    // opened without the ?token= query param. Show an error state instead of
    // rendering the form, which would only fail at submission time.
    // Extracted to a separate widget so that hooks below are always called
    // unconditionally (HookWidget rules of hooks).
    if (token.isEmpty) {
      return _MissingTokenView(l10n: l10n);
    }

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final state = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);

    return AuthShell(
      title: l10n.authResetPasswordAction,
      subtitle: l10n.authResetPasswordSubtitle,
      logo: const AuthBrandLogo(),
      leading: const AppBackButton(fallbackRoute: Routes.home),
      centerTitle: true,
      form: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FTextFormField.password(
              control: FTextFieldControl.managed(
                controller: passwordController,
              ),
              label: Text(l10n.authNewPasswordLabel),
              hint: l10n.authPasswordHint,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  PasswordInput.validate(value, l10n.authPasswordRequiredError),
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
                        final password = passwordController.text;
                        notifier.updatePassword(password);
                        notifier.updateConfirmPassword(
                          confirmPasswordController.text,
                        );
                        final ok = await notifier.resetPassword(
                          token: token,
                          password: password,
                        );
                        if (!ok && context.mounted) {
                          final msg = ref
                              .read(passwordResetProvider)
                              .errorMessage;
                          if (msg != null && msg.isNotEmpty) {
                            await Toast.show(context, msg);
                          }
                          return;
                        }
                        if (ok && context.mounted) {
                          await Toast.show(
                            context,
                            l10n.authResetPasswordSuccess,
                          );
                          if (context.mounted) {
                            context.go(Routes.login);
                          }
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
          ],
        ),
      ),
    );
  }
}

/// Error state shown when the reset-password deep link is missing the
/// `?token=` query parameter. Extracted from [ResetPasswordPage.build] so
/// that hooks in the main build path are always called unconditionally,
/// satisfying the rules of hooks for [HookConsumerWidget].
class _MissingTokenView extends StatelessWidget {
  const _MissingTokenView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: l10n.authResetPasswordMissingTokenTitle,
      subtitle: l10n.authResetPasswordMissingTokenMessage,
      logo: const AuthBrandLogo(),
      leading: const AppBackButton(fallbackRoute: Routes.login),
      centerTitle: true,
      form: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.authResetPasswordMissingTokenMessage,
            style: context.theme.typography.body.sm,
          ),
          const SizedBox(height: Spacing.level6),
          SizedBox(
            width: double.infinity,
            child: FButton(
              onPress: () => context.go(Routes.forgotPassword),
              child: Text(l10n.authResetPasswordMissingTokenAction),
            ),
          ),
        ],
      ),
    );
  }
}
