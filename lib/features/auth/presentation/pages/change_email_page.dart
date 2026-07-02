import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
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
    final formKey = useMemoized(GlobalKey<FormState>.new);
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

    return AuthShell(
      title: l10n?.authChangeEmailFormTitle ?? 'Change email',
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
                    label: Text(l10n?.authNewEmailLabel ?? 'New email'),
                    hint: l10n?.authEmailHint ?? 'name@example.com',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => _validateEmail(
                      value,
                      requiredMessage:
                          l10n?.authEmailRequiredError ??
                          'Please enter your email.',
                      invalidMessage:
                          l10n?.authEmailInvalidError ??
                          'Please enter a valid email address.',
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  _VerificationCodeField(
                    controller: codeController,
                    label: l10n?.authCodeLabel ?? 'Verification code',
                    hint: l10n?.authCodeLabel ?? 'Verification code',
                    buttonLabel: accountState.lastCooldownSeconds == null
                        ? l10n?.authSendCode ?? 'Send code'
                        : l10n?.authSendCodeAgain(
                                accountState.lastCooldownSeconds!,
                              ) ??
                              'Send again (${accountState.lastCooldownSeconds}s)',
                    isLoading: accountState.isSendingCode,
                    validator: (value) => _validateRequired(
                      value,
                      l10n?.authCodeRequiredError ??
                          'Please enter the verification code.',
                    ),
                    onSendCode: !isSignedIn
                        ? null
                        : () async {
                            final emailError = _validateEmail(
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
                            await accountNotifier.sendVerificationCode(
                              email: emailController.text,
                              scene: AuthVerificationScene.changeEmail,
                            );
                          },
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
                  const SizedBox(height: AppSpacingTokens.xl),
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
                                    l10n?.authChangeEmailSuccess ??
                                        'Email updated.',
                                  );
                                }
                              },
                        child: accountState.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l10n?.authChangeEmailSubmit ?? 'Update email',
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          !isSignedIn
                              ? l10n?.authNotSignedIn ?? 'Not signed in yet.'
                              : l10n?.authBackHomePrompt ?? 'Back to home?',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                        ),
                      ),
                      FButton(
                        variant: FButtonVariant.ghost,
                        size: FButtonSizeVariant.sm,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () =>
                            context.push(!isSignedIn ? '/login' : '/'),
                        child: Text(
                          !isSignedIn
                              ? l10n?.authSignIn ?? 'Sign in'
                              : l10n?.todayHeroTitle ?? 'Today',
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

class _VerificationCodeField extends StatelessWidget {
  const _VerificationCodeField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    required this.buttonLabel,
    required this.isLoading,
    required this.onSendCode,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String buttonLabel;
  final bool isLoading;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onSendCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FTextFormField(
            control: FTextFieldControl.managed(controller: controller),
            label: Text(label),
            hint: hint,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
          ),
        ),
        const SizedBox(width: AppSpacingTokens.sm),
        SizedBox(
          width: 148,
          child: Padding(
            padding: const EdgeInsets.only(top: 26),
            child: FButton(
              variant: FButtonVariant.outline,
              onPress: isLoading ? null : onSendCode,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(buttonLabel),
            ),
          ),
        ),
      ],
    );
  }
}

String? _validateRequired(String? value, String message) {
  if ((value ?? '').trim().isEmpty) {
    return message;
  }
  return null;
}

String? _validateEmail(
  String? value, {
  required String requiredMessage,
  required String invalidMessage,
}) {
  final trimmed = (value ?? '').trim();
  if (trimmed.isEmpty) {
    return requiredMessage;
  }
  if (!trimmed.contains('@')) {
    return invalidMessage;
  }
  return null;
}
