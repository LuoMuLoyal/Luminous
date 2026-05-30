import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/auth/presentation/providers/login_form_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return AuthShell(
      badge: 'AUTH / LOGIN',
      title: 'Sign in with calm, not clutter.',
      description:
          'Use your Lucent account to unlock the rebuilt medication flow, multilingual responses, and secure session restore.',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Welcome back', style: typography.displayMd),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            'Start with email, then choose password or verification code.',
            style: typography.bodySm.copyWith(color: surface.body),
          ),
          const SizedBox(height: AppSpacingTokens.xl),
          SegmentedButton<AuthLoginMode>(
            segments: const <ButtonSegment<AuthLoginMode>>[
              ButtonSegment<AuthLoginMode>(
                value: AuthLoginMode.password,
                label: Text('Password'),
              ),
              ButtonSegment<AuthLoginMode>(
                value: AuthLoginMode.code,
                label: Text('Code'),
              ),
            ],
            selected: <AuthLoginMode>{state.mode},
            onSelectionChanged: (next) {
              notifier.updateMode(next.first);
            },
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          if (state.mode == AuthLoginMode.password)
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
            )
          else
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _codeController,
                    label: 'Verification code',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                OutlinedButton(
                  onPressed: () async {
                    notifier.updateEmail(_emailController.text);
                    await notifier.sendCode();
                  },
                  child: const Text('Send code'),
                ),
              ],
            ),
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: AppSpacingTokens.md),
            Text(
              state.errorMessage!,
              style: typography.bodySm.copyWith(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            label: 'Sign in',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(_emailController.text);
              notifier.updatePassword(_passwordController.text);
              notifier.updateCode(_codeController.text);
              await notifier.submit();
            },
          ),
        ],
      ),
    );
  }
}
