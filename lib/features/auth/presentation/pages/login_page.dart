import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/presentation/providers/login_form_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({
    super.key,
    this.wechatCode,
    this.wechatState,
    this.returnTo,
  });

  final String? wechatCode;
  final String? wechatState;
  final String? returnTo;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _codeController;
  late final TextEditingController _wechatCallbackController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _codeController = TextEditingController();
    _wechatCallbackController = TextEditingController();

    if ((widget.wechatCode?.isNotEmpty ?? false) &&
        (widget.wechatState?.isNotEmpty ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _completeWechatLogin(widget.wechatCode!, widget.wechatState!);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    _wechatCallbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return AuthShell(
      title: l10n?.authSignIn ?? 'Sign in',
      centerTitle: true,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<AuthLoginMode>(
              segments: <ButtonSegment<AuthLoginMode>>[
                ButtonSegment<AuthLoginMode>(
                  value: AuthLoginMode.password,
                  label: SizedBox(
                    width: 96,
                    child: Text(
                      l10n?.authModePassword ?? 'Password',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ButtonSegment<AuthLoginMode>(
                  value: AuthLoginMode.code,
                  label: SizedBox(
                    width: 96,
                    child: Text(
                      l10n?.authModeCode ?? 'Code',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              selected: <AuthLoginMode>{state.mode},
              onSelectionChanged: (next) {
                notifier.updateMode(next.first);
              },
            ),
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          AuthTextField(
            controller: _emailController,
            label: l10n?.authEmailLabel ?? 'Email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AnimatedSwitcher(
            duration: 160.ms,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: state.mode == AuthLoginMode.password
                ? AuthTextField(
                    key: const ValueKey('password-login-field'),
                    controller: _passwordController,
                    label: l10n?.authPasswordLabel ?? 'Password',
                    hint:
                        l10n?.authPasswordHint ??
                        'At least 8 characters, ideally with mixed case and numbers',
                    obscureText: true,
                  )
                : AuthCodeFieldRow(
                    key: const ValueKey('code-login-field'),
                    controller: _codeController,
                    label: l10n?.authCodeLabel ?? 'Verification code',
                    buttonLabel: l10n?.authSendCode ?? 'Send code',
                    isLoading: state.isSendingCode,
                    onSendCode: () async {
                      notifier.updateEmail(_emailController.text);
                      if (_emailController.text.trim().isEmpty) {
                        await AppToast.show(
                          context,
                          l10n?.authEmailRequiredToast ??
                              'Please enter your email.',
                        );
                        return;
                      }
                      await notifier.sendCode();
                    },
                  ),
          ),
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AuthStatusMessage(error: state.errorMessage),
          ],
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            label: l10n?.authSignIn ?? 'Sign in',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(_emailController.text);
              notifier.updatePassword(_passwordController.text);
              notifier.updateCode(_codeController.text);
              if (!_validateSubmit(context, l10n, state.mode)) {
                return;
              }
              final session = await notifier.submit();
              if (session != null && context.mounted) {
                _goAfterLogin();
              }
            },
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          AuthLoginActionRow(
            registerPrompt: l10n?.authNeedAccountPrompt ?? 'Need an account?',
            registerLabel: l10n?.authRegisterNowAction ?? 'Register now',
            onRegister: () => context.push('/register'),
            forgotPasswordLabel:
                l10n?.authForgotPasswordPrompt ?? 'Forgot your password?',
            onForgotPassword: () => context.push('/forgot-password'),
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          _WechatOAuthPanel(
            callbackController: _wechatCallbackController,
            isStarting: state.isStartingWechatLogin,
            isCompleting: state.isCompletingWechatLogin,
            authorizeUrl: state.wechatAuthorizeUrl,
            onStart: () => _startWechatLogin(context, l10n),
            onComplete: () => _completeWechatLoginFromInput(context, l10n),
          ),
        ],
      ),
    );
  }

  Future<void> _startWechatLogin(
    BuildContext context,
    AppLocalizations? l10n,
  ) async {
    final notifier = ref.read(loginFormProvider.notifier);
    final mobileSession = await notifier.startWechatMobileLogin();
    if (mobileSession != null) {
      if (context.mounted) {
        _goAfterLogin(fallbackHome: true);
      }
      return;
    }
    final afterMobileAttempt = ref.read(loginFormProvider);
    if (afterMobileAttempt.errorMessage?.isNotEmpty == true) {
      return;
    }

    final desktopSession = await notifier.startWechatDesktopWebLogin();
    if (desktopSession != null) {
      if (context.mounted) {
        _goAfterLogin(fallbackHome: true);
      }
      return;
    }
    final afterDesktopAttempt = ref.read(loginFormProvider);
    if (afterDesktopAttempt.errorMessage?.isNotEmpty == true) {
      return;
    }

    final authorize = await notifier.createWechatWebAuthorizeUrl(
      callbackUri: _webWechatCallbackUri(),
    );
    if (authorize == null || !context.mounted) {
      return;
    }

    final opened = await ref
        .read(externalUrlLauncherProvider)
        .open(Uri.parse(authorize.authorizeUrl));
    if (!context.mounted) {
      return;
    }
    if (!opened) {
      await AppToast.show(
        context,
        l10n?.authWechatBrowserOpenFailed ??
            'Could not open the WeChat authorization page.',
      );
      return;
    }
    await AppToast.show(
      context,
      l10n?.authWechatAuthorizeOpened ??
          'WeChat authorization opened in your browser.',
    );
  }

  String? _webWechatCallbackUri() {
    if (!kIsWeb) {
      return null;
    }

    final base = Uri.base;
    final returnTo = _safeReturnTo(widget.returnTo);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/login/oauth/wechat',
      queryParameters: returnTo == null ? null : {'returnTo': returnTo},
    ).toString();
  }

  Future<void> _completeWechatLoginFromInput(
    BuildContext context,
    AppLocalizations? l10n,
  ) async {
    final notifier = ref.read(loginFormProvider.notifier);
    notifier.updateWechatCallbackInput(_wechatCallbackController.text);
    final state = ref.read(loginFormProvider);
    final callback = _parseWechatCallback(
      _wechatCallbackController.text,
      state.wechatState,
    );
    if (callback == null) {
      final message = _wechatCallbackController.text.trim().isEmpty
          ? l10n?.authWechatCallbackRequiredToast ??
                'Paste the WeChat callback link first.'
          : l10n?.authWechatCallbackInvalidToast ??
                'The WeChat callback link is missing code or state.';
      await AppToast.show(context, message);
      return;
    }
    await _completeWechatLogin(callback.code, callback.state);
  }

  Future<void> _completeWechatLogin(String code, String state) async {
    final session = await ref
        .read(loginFormProvider.notifier)
        .completeWechatWebLogin(code: code, state: state);
    if (session == null || !mounted) {
      return;
    }
    _goAfterLogin(fallbackHome: true);
  }

  void _goAfterLogin({bool fallbackHome = false}) {
    final target = _safeReturnTo(widget.returnTo);
    if (target != null) {
      context.go(target);
      return;
    }
    if (fallbackHome) {
      context.go('/');
    }
  }

  String? _safeReturnTo(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    if (!trimmed.startsWith('/') || trimmed.startsWith('//')) {
      return null;
    }
    if (trimmed == '/login' ||
        trimmed.startsWith('/login?') ||
        trimmed.startsWith('/login/')) {
      return null;
    }
    return trimmed;
  }

  _WechatCallback? _parseWechatCallback(String raw, String? fallbackState) {
    final input = raw.trim();
    if (input.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(input);
    final uriCode = uri?.queryParameters['code']?.trim();
    final uriState = uri?.queryParameters['state']?.trim();
    if (uriCode?.isNotEmpty == true &&
        (uriState?.isNotEmpty == true || fallbackState?.isNotEmpty == true)) {
      return _WechatCallback(
        code: uriCode!,
        state: uriState?.isNotEmpty == true ? uriState! : fallbackState!,
      );
    }

    final query = input.startsWith('?') ? input.substring(1) : input;
    if (query.contains('=')) {
      try {
        final values = Uri.splitQueryString(query);
        final code = values['code']?.trim();
        final state = values['state']?.trim();
        if (code?.isNotEmpty == true &&
            (state?.isNotEmpty == true || fallbackState?.isNotEmpty == true)) {
          return _WechatCallback(
            code: code!,
            state: state?.isNotEmpty == true ? state! : fallbackState!,
          );
        }
      } on FormatException {
        return null;
      }
    }

    if (!input.contains(RegExp(r'\s')) && fallbackState?.isNotEmpty == true) {
      return _WechatCallback(code: input, state: fallbackState!);
    }

    return null;
  }

  bool _validateSubmit(
    BuildContext context,
    AppLocalizations? l10n,
    AuthLoginMode mode,
  ) {
    final message = switch ((
      _emailController.text.trim().isEmpty,
      mode == AuthLoginMode.password && _passwordController.text.trim().isEmpty,
      mode == AuthLoginMode.code && _codeController.text.trim().isEmpty,
    )) {
      (true, _, _) =>
        l10n?.authEmailRequiredToast ?? 'Please enter your email.',
      (_, true, _) =>
        l10n?.authPasswordRequiredToast ?? 'Please enter your password.',
      (_, _, true) =>
        l10n?.authCodeRequiredToast ?? 'Please enter the verification code.',
      _ => null,
    };
    if (message == null) {
      return true;
    }
    AppToast.show(context, message);
    return false;
  }
}

class _WechatOAuthPanel extends StatelessWidget {
  const _WechatOAuthPanel({
    required this.callbackController,
    required this.isStarting,
    required this.isCompleting,
    required this.authorizeUrl,
    required this.onStart,
    required this.onComplete,
  });

  final TextEditingController callbackController;
  final bool isStarting;
  final bool isCompleting;
  final String? authorizeUrl;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: const Key('wechat-login-start-button'),
          onPressed: isStarting || isCompleting ? null : onStart,
          icon: isStarting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.qr_code_rounded, size: 18),
          label: Text(l10n?.authWechatSignIn ?? 'Sign in with WeChat'),
        ),
        if (authorizeUrl?.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacingTokens.md),
          AuthTextField(
            key: const Key('wechat-callback-input'),
            controller: callbackController,
            label:
                l10n?.authWechatCallbackLabel ?? 'WeChat callback link / code',
            hint:
                l10n?.authWechatCallbackHint ??
                'Paste the callback URL after scanning',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AuthPrimaryButton(
            label: l10n?.authWechatCompleteAction ?? 'Complete WeChat sign-in',
            isLoading: isCompleting,
            onPressed: onComplete,
          ),
        ],
      ],
    );
  }
}

class _WechatCallback {
  const _WechatCallback({required this.code, required this.state});

  final String code;
  final String state;
}
