import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/register_form_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _codeController = TextEditingController();
    _passwordController = TextEditingController();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerFormProvider);
    final notifier = ref.read(registerFormProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return AuthShell(
      title: l10n?.authCreateAccountAction ?? 'Create account',
      subtitle: l10n?.authRegisterSubtitle,
      logo: const AuthBrandLogo(),
      centerTitle: true,
      form: Column(
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
          const SizedBox(height: AppSpacingTokens.md),
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
              if (_emailController.text.trim().isEmpty) {
                await AppToast.show(
                  context,
                  l10n?.authEmailRequiredToast ?? 'Please enter your email.',
                );
                return;
              }
              await notifier.sendCode();
            },
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AuthTextField(
            controller: _passwordController,
            label: l10n?.authPasswordLabel ?? 'Password',
            hint:
                l10n?.authPasswordHint ??
                'At least 8 characters, ideally with mixed case and numbers',
            obscureText: true,
            prefix: const Icon(Icons.lock_outline),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AuthTextField(
            controller: _nicknameController,
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
              notifier.updateEmail(_emailController.text);
              notifier.updateCode(_codeController.text);
              notifier.updatePassword(_passwordController.text);
              notifier.updateNickname(_nicknameController.text);
              if (!_validateSubmit(context, l10n)) {
                return;
              }
              await notifier.submit();
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

  bool _validateSubmit(BuildContext context, AppLocalizations? l10n) {
    final message = switch ((
      _emailController.text.trim().isEmpty,
      _codeController.text.trim().isEmpty,
      _passwordController.text.trim().isEmpty,
    )) {
      (true, _, _) =>
        l10n?.authEmailRequiredToast ?? 'Please enter your email.',
      (_, true, _) =>
        l10n?.authCodeRequiredToast ?? 'Please enter the verification code.',
      (_, _, true) =>
        l10n?.authPasswordRequiredToast ?? 'Please enter your password.',
      _ => null,
    };
    if (message == null) {
      return true;
    }
    AppToast.show(context, message);
    return false;
  }
}
