import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/presentation/providers/forms/register_form_provider.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final codeController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final nicknameController = useTextEditingController();
    final acceptedTerms = useState(false);

    final state = ref.watch(registerFormProvider);
    final notifier = ref.read(registerFormProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final urlLauncher = ref.read(externalUrlLauncherProvider);

    return AuthShell(
      title: l10n?.authCreateAccountAction ?? 'Create account',
      subtitle: l10n?.authRegisterSubtitle,
      logo: const AuthBrandLogo(),
      leading: const AppBackButton(fallbackRoute: '/'),
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
              validator: (value) => _validateEmail(
                value,
                requiredMessage:
                    l10n?.authEmailRequiredError ?? 'Please enter your email.',
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
              buttonLabel: state.cooldownSeconds == null
                  ? l10n?.authSendCode ?? 'Send code'
                  : l10n?.authSendCodeAgain(state.cooldownSeconds!) ??
                        'Send again (${state.cooldownSeconds}s)',
              isLoading: state.isSendingCode,
              validator: (value) => _validateRequired(
                value,
                l10n?.authCodeRequiredError ??
                    'Please enter the verification code.',
              ),
              onSendCode: () async {
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
                await notifier.sendCode();
              },
            ),
            const SizedBox(height: AppSpacingTokens.md),
            FTextFormField.password(
              control: FTextFieldControl.managed(
                controller: passwordController,
              ),
              label: Text(l10n?.authPasswordLabel ?? 'Password'),
              hint:
                  l10n?.authPasswordHint ??
                  'At least 8 characters, ideally with mixed case and numbers',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => _validateRequired(
                value,
                l10n?.authPasswordRequiredError ??
                    'Please enter your password.',
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
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
                final requiredError = _validateRequired(
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
            const SizedBox(height: AppSpacingTokens.md),
            FTextFormField(
              control: FTextFieldControl.managed(
                controller: nicknameController,
              ),
              label: Text(l10n?.authNicknameLabel ?? 'Nickname'),
              hint: l10n?.authNicknameHint ?? 'Optional',
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: AppSpacingTokens.md),
            FCheckbox(
              value: acceptedTerms.value,
              onChange: (value) => acceptedTerms.value = value,
              semanticsLabel:
                  l10n?.authTermsAgreement(
                    l10n.authTermsOfService,
                    l10n.authPrivacyPolicy,
                  ) ??
                  'By creating an account, you agree to the Terms of Service and Privacy Policy',
              label: Text(
                l10n?.authTermsAgreement(
                      l10n.authTermsOfService,
                      l10n.authPrivacyPolicy,
                    ) ??
                    'By creating an account, you agree to the Terms of Service and Privacy Policy',
              ),
              description: _TermsLinks(
                onTerms: () => _openLegalUrl(
                  context,
                  urlLauncher,
                  'https://luminous.app/terms',
                ),
                onPrivacy: () => _openLegalUrl(
                  context,
                  urlLauncher,
                  'https://luminous.app/privacy',
                ),
              ),
            ),
            if ((state.errorMessage?.isNotEmpty ?? false) ||
                (state.successMessage?.isNotEmpty ?? false)) ...[
              const SizedBox(height: AppSpacingTokens.md),
              FToast(
                variant: state.errorMessage?.isNotEmpty == true
                    ? FToastVariant.destructive
                    : FToastVariant.primary,
                title: Text(
                  state.errorMessage?.isNotEmpty == true
                      ? state.errorMessage!
                      : state.successMessage!,
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
                  onPress: state.isSubmitting || !acceptedTerms.value
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
                          notifier.updateNickname(nicknameController.text);
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
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n?.authCreateAccountAction ?? 'Create account'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n?.authHaveAccountPrompt ?? 'Already have an account?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => context.push('/login'),
                  child: Text(l10n?.authSignIn ?? 'Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
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
  final VoidCallback onSendCode;

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

Future<void> _openLegalUrl(
  BuildContext context,
  ExternalUrlLauncher launcher,
  String url,
) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return;
  }
  await launcher.open(uri);
}

class _TermsLinks extends StatelessWidget {
  const _TermsLinks({required this.onTerms, required this.onPrivacy});

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final linkStyle = textTheme.bodySmall?.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w600,
    );

    return Wrap(
      spacing: AppSpacingTokens.xs,
      runSpacing: AppSpacingTokens.xxs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FButton(
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.sm,
          mainAxisSize: MainAxisSize.min,
          onPress: onTerms,
          child: Text(l10n.authTermsOfService, style: linkStyle),
        ),
        Text(
          '/',
          style: textTheme.bodySmall?.copyWith(color: colors.mutedForeground),
        ),
        FButton(
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.sm,
          mainAxisSize: MainAxisSize.min,
          onPress: onPrivacy,
          child: Text(l10n.authPrivacyPolicy, style: linkStyle),
        ),
      ],
    );
  }
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
