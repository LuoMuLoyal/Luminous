import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/features/auth/presentation/providers/forms/register.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/shell.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/verification_code_field.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return AuthShell(
      title: l10n.authCreateAccountAction,
      subtitle: l10n.authRegisterSubtitle,
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
                      final ok = await notifier.sendCode();
                      if (!ok && context.mounted) {
                        final msg = ref.read(registerFormProvider).errorMessage;
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
              label: Text(l10n.authPasswordLabel),
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
            const SizedBox(height: Spacing.level4),
            FTextFormField(
              control: FTextFieldControl.managed(
                controller: nicknameController,
              ),
              label: Text(l10n.authNicknameLabel),
              hint: l10n.authNicknameHint,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: Spacing.level4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FCheckbox(
                  value: acceptedTerms.value,
                  onChange: (value) => acceptedTerms.value = value,
                  semanticsLabel: l10n.authTermsAgreement(
                    l10n.authTermsOfService,
                    l10n.authPrivacyPolicy,
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                Expanded(
                  child: _TermsAgreementText(
                    terms: l10n.authTermsOfService,
                    privacy: l10n.authPrivacyPolicy,
                    onTerms: () => context.push('${Routes.legal}/terms'),
                    onPrivacy: () => context.push('${Routes.legal}/privacy'),
                  ),
                ),
              ],
            ),
            if (!acceptedTerms.value)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.level2),
                child: Text(
                  l10n.authRegisterTermsRequiredHint,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: context.theme.colors.destructive),
                ),
              ),
            const SizedBox(height: Spacing.level6),
            SizedBox(
              width: double.infinity,
              child: FButton(
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
                        if (!ok && context.mounted) {
                          final msg =
                              ref
                                      .read(registerFormProvider)
                                      .errorMessage
                                      ?.isNotEmpty ==
                                  true
                              ? ref.read(registerFormProvider).errorMessage!
                              : null;
                          if (msg != null) {
                            await Toast.show(context, msg);
                          }
                        }
                        if (ok && context.mounted) {
                          await Toast.show(context, l10n.authRegisterSuccess);
                          if (!context.mounted) {
                            return;
                          }
                          context.go(Routes.login);
                        }
                      },
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: FCircularProgress(),
                      )
                    : Text(l10n.authCreateAccountAction),
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
                  l10n.authHaveAccountPrompt,
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

class _TermsAgreementText extends StatefulWidget {
  const _TermsAgreementText({
    required this.terms,
    required this.privacy,
    required this.onTerms,
    required this.onPrivacy,
  });

  final String terms;
  final String privacy;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  State<_TermsAgreementText> createState() => _TermsAgreementTextState();
}

class _TermsAgreementTextState extends State<_TermsAgreementText> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = widget.onTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = widget.onPrivacy;
  }

  @override
  void didUpdateWidget(covariant _TermsAgreementText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTerms != widget.onTerms) {
      _termsRecognizer.onTap = widget.onTerms;
    }
    if (oldWidget.onPrivacy != widget.onPrivacy) {
      _privacyRecognizer.onTap = widget.onPrivacy;
    }
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final baseStyle = TypographyToken.level3.body(context);
    final linkStyle = baseStyle.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w600,
    );
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: l10n.authTermsAgreement('', '')),
            TextSpan(
              text: widget.terms,
              style: linkStyle,
              recognizer: _termsRecognizer,
            ),
            const TextSpan(text: ' / '),
            TextSpan(
              text: widget.privacy,
              style: linkStyle,
              recognizer: _privacyRecognizer,
            ),
          ],
        ),
      ),
    );
  }
}
