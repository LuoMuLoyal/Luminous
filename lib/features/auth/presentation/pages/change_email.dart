import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ChangeEmailPage extends HookConsumerWidget {
  const ChangeEmailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final codeController = useTextEditingController();

    final accountState = ref.watch(authAccountProvider);
    final accountNotifier = ref.read(authAccountProvider.notifier);
    final session = ref.watch(authSessionProvider);
    final l10n = AppLocalizations.of(context)!;
    final isSignedIn = session.canAccessProtectedData && session.user != null;
    final success = accountState.successMessage?.isNotEmpty == true
        ? accountState.successMessage
        : null;

    return AuthShell(
      title: l10n.authChangeEmailFormTitle,
      leading: const AppBackButton(),
      centerTitle: true,
      form: session.isLoading
          ? const _ChangeEmailLoading()
          : Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FTextFormField.email(
                    control: FTextFieldControl.managed(
                      controller: emailController,
                    ),
                    label: Text(l10n.authNewEmailLabel),
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
                    buttonLabel: accountState.lastCooldownSeconds == null
                        ? l10n.authSendCode
                        : l10n.authSendCodeAgain(
                            accountState.lastCooldownSeconds!,
                          ),
                    isLoading: accountState.isSendingCode,
                    validator: (value) => RequiredInput.validate(
                      value,
                      l10n.authCodeRequiredError,
                    ),
                    onSendCode: !isSignedIn
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
                            await accountNotifier.sendVerificationCode(
                              email: emailController.text,
                              scene: AuthVerificationScene.changeEmail,
                            );
                          },
                  ),
                  if ((accountState.errorMessage?.isNotEmpty ?? false) ||
                      success != null) ...[
                    const SizedBox(height: Spacing.level4),
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
                  const SizedBox(height: Spacing.level6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FButton(
                        size: FButtonSizeVariant.sm,
                        mainAxisSize: MainAxisSize.min,
                        onPress: !isSignedIn || accountState.isSubmitting
                            ? null
                            : () async {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                                final ok = await accountNotifier.changeEmail(
                                  newEmail: emailController.text,
                                  code: codeController.text,
                                );
                                if (ok && context.mounted) {
                                  await AppToast.show(
                                    context,
                                    l10n.authChangeEmailSuccess,
                                  );
                                }
                              },
                        child: accountState.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: FCircularProgress(),
                              )
                            : Text(l10n.authChangeEmailSubmit),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.level3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          !isSignedIn
                              ? l10n.authNotSignedIn
                              : l10n.authBackHomePrompt,
                          style: TypographyToken.level3
                              .body(context)
                              .copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                        ),
                      ),
                      FButton(
                        variant: FButtonVariant.ghost,
                        size: FButtonSizeVariant.sm,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => context.push(
                          !isSignedIn ? AppRoutes.login : AppRoutes.home,
                        ),
                        child: Text(
                          !isSignedIn
                              ? l10n.authSignIn
                              : l10n.authBackHomeAction,
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
