import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/presentation/providers/forms/login_form_provider.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({
    super.key,
    this.wechatCode,
    this.wechatState,
    this.qqCode,
    this.qqState,
    this.returnTo,
  });

  final String? wechatCode;
  final String? wechatState;
  final String? qqCode;
  final String? qqState;
  final String? returnTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final codeController = useTextEditingController();
    final wechatCallbackController = useTextEditingController();
    final qqCallbackController = useTextEditingController();

    final state = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    final l10n = AppLocalizations.of(context);

    // ---- helper functions (formerly class methods) ----

    String? safeReturnTo(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return null;
      if (!trimmed.startsWith('/') || trimmed.startsWith('//')) return null;
      if (trimmed == '/login' ||
          trimmed.startsWith('/login?') ||
          trimmed.startsWith('/login/')) {
        return null;
      }
      return trimmed;
    }

    void goAfterLogin({bool fallbackHome = false}) {
      final target = safeReturnTo(returnTo);
      if (target != null) {
        context.go(target);
        return;
      }
      if (fallbackHome) context.go('/');
    }

    String? webWechatCallbackUri() {
      if (!kIsWeb) return null;
      final base = Uri.base;
      final rt = safeReturnTo(returnTo);
      return Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: '/login/oauth/wechat',
        queryParameters: rt == null ? null : {'returnTo': rt},
      ).toString();
    }

    String? webQqCallbackUri() {
      if (!kIsWeb) return null;
      final base = Uri.base;
      final rt = safeReturnTo(returnTo);
      return Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: '/login/oauth/qq',
        queryParameters: rt == null ? null : {'returnTo': rt},
      ).toString();
    }

    _WechatCallback? parseWechatCallback(String raw, String? fallbackState) {
      final input = raw.trim();
      if (input.isEmpty) return null;

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
              (state?.isNotEmpty == true ||
                  fallbackState?.isNotEmpty == true)) {
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

    Future<void> completeWechatLogin(String code, String state) async {
      final session = await ref
          .read(loginFormProvider.notifier)
          .completeWechatWebLogin(code: code, state: state);
      if (session == null || !context.mounted) return;
      goAfterLogin(fallbackHome: true);
    }

    Future<void> completeQqLogin(String code, String state) async {
      final session = await ref
          .read(loginFormProvider.notifier)
          .completeQqLogin(code: code, state: state);
      if (session == null || !context.mounted) return;
      goAfterLogin(fallbackHome: true);
    }

    Future<void> startWechatLogin(BuildContext ctx, AppLocalizations? l) async {
      final n = ref.read(loginFormProvider.notifier);
      final mobileSession = await n.startWechatMobileLogin();
      if (mobileSession != null) {
        if (ctx.mounted) goAfterLogin(fallbackHome: true);
        return;
      }
      final afterMobileAttempt = ref.read(loginFormProvider);
      if (afterMobileAttempt.errorMessage?.isNotEmpty == true) return;

      final desktopSession = await n.startWechatDesktopWebLogin();
      if (desktopSession != null) {
        if (ctx.mounted) goAfterLogin(fallbackHome: true);
        return;
      }
      final afterDesktopAttempt = ref.read(loginFormProvider);
      if (afterDesktopAttempt.errorMessage?.isNotEmpty == true) return;

      final authorize = await n.createWechatWebAuthorizeUrl(
        callbackUri: webWechatCallbackUri(),
      );
      if (authorize == null || !ctx.mounted) return;

      final opened = await ref
          .read(externalUrlLauncherProvider)
          .open(Uri.parse(authorize.authorizeUrl));
      if (!ctx.mounted) return;
      if (!opened) {
        await AppToast.show(
          ctx,
          l?.authWechatBrowserOpenFailed ??
              'Could not open the WeChat authorization page.',
        );
        return;
      }
      await AppToast.show(
        ctx,
        l?.authWechatAuthorizeOpened ??
            'WeChat authorization opened in your browser.',
      );
    }

    Future<void> completeWechatLoginFromInput(
      BuildContext ctx,
      AppLocalizations? l,
    ) async {
      final n = ref.read(loginFormProvider.notifier);
      n.updateWechatCallbackInput(wechatCallbackController.text);
      final st = ref.read(loginFormProvider);
      final callback = parseWechatCallback(
        wechatCallbackController.text,
        st.wechatState,
      );
      if (callback == null) {
        final message = wechatCallbackController.text.trim().isEmpty
            ? l?.authWechatCallbackRequiredToast ??
                  'Paste the WeChat callback link first.'
            : l?.authWechatCallbackInvalidToast ??
                  'The WeChat callback link is missing code or state.';
        await AppToast.show(ctx, message);
        return;
      }
      await completeWechatLogin(callback.code, callback.state);
    }

    Future<void> startQqLogin(BuildContext ctx, AppLocalizations? l) async {
      final n = ref.read(loginFormProvider.notifier);
      final authorize = await n.createQqAuthorizeUrl(
        callbackUri: webQqCallbackUri(),
      );
      if (authorize == null || !ctx.mounted) return;

      final opened = await ref
          .read(externalUrlLauncherProvider)
          .open(Uri.parse(authorize.authorizeUrl));
      if (!ctx.mounted) return;
      if (!opened) {
        await AppToast.show(
          ctx,
          l?.authWechatBrowserOpenFailed ??
              'Could not open the QQ authorization page.',
        );
        return;
      }
      await AppToast.show(ctx, 'QQ authorization opened in your browser.');
    }

    Future<void> completeQqLoginFromInput(
      BuildContext ctx,
      AppLocalizations? l,
    ) async {
      final n = ref.read(loginFormProvider.notifier);
      n.updateQqCallbackInput(qqCallbackController.text);
      final st = ref.read(loginFormProvider);
      final callback = parseWechatCallback(
        qqCallbackController.text,
        st.qqState,
      );
      if (callback == null) {
        final message = qqCallbackController.text.trim().isEmpty
            ? 'Please paste the QQ callback link first.'
            : 'The QQ callback link is missing code or state.';
        await AppToast.show(ctx, message);
        return;
      }
      await completeQqLogin(callback.code, callback.state);
    }

    Future<void> startAppleLogin() async {
      if (!context.mounted) return;
      final l = AppLocalizations.of(context);
      final failMessage =
          l?.authWechatBrowserOpenFailed ?? 'Apple Sign In failed.';
      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        if (!context.mounted) return;
        final session = await ref
            .read(loginFormProvider.notifier)
            .loginWithApple(
              identityToken: credential.identityToken ?? '',
              authorizationCode: credential.authorizationCode,
              givenName: credential.givenName,
              familyName: credential.familyName,
            );
        if (session == null || !context.mounted) return;
        goAfterLogin(fallbackHome: true);
      } catch (e) {
        if (context.mounted) await AppToast.show(context, failMessage);
      }
    }

    // Handle OAuth callbacks on first build (initState equivalent)
    useEffect(() {
      if ((wechatCode?.isNotEmpty ?? false) &&
          (wechatState?.isNotEmpty ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          completeWechatLogin(wechatCode!, wechatState!);
        });
      }
      if ((qqCode?.isNotEmpty ?? false) && (qqState?.isNotEmpty ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          completeQqLogin(qqCode!, qqState!);
        });
      }
      return null;
    }, []);

    // ---- build UI ----

    return AuthShell(
      title: l10n?.authWelcomeBack ?? 'Welcome back',
      subtitle: l10n?.authLoginSubtitle,
      logo: const AuthBrandLogo(),
      leading: const AppBackButton(fallbackRoute: '/'),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthTextField(
                key: const Key('auth-login-email-field'),
                controller: emailController,
                label: l10n?.authEmailLabel ?? 'Email',
                hint: l10n?.authEmailHint ?? 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(Icons.mail_outline),
              ),
              AuthFieldError(state.emailError),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.md),
          if (state.mode == AuthLoginMode.password)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthTextField(
                      key: const ValueKey('password-login-field'),
                      controller: passwordController,
                      label: l10n?.authPasswordLabel ?? 'Password',
                      hint:
                          l10n?.authPasswordHint ??
                          'At least 8 characters, ideally with mixed case and numbers',
                      obscureText: true,
                      prefix: const Icon(Icons.lock_outline),
                    )
                    .animate(key: const ValueKey('password-field-anim'))
                    .fadeIn(duration: 160.ms, curve: Curves.easeOutCubic)
                    .slideX(
                      begin: 0.02,
                      end: 0,
                      duration: 160.ms,
                      curve: Curves.easeOutCubic,
                    ),
                AuthFieldError(state.passwordError),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthCodeFieldRow(
                      key: const ValueKey('auth-login-code-field'),
                      controller: codeController,
                      label: l10n?.authCodeLabel ?? 'Verification code',
                      buttonLabel: state.cooldownSeconds == null
                          ? l10n?.authSendCode ?? 'Send code'
                          : l10n?.authSendCodeAgain(state.cooldownSeconds!) ??
                                'Send again (${state.cooldownSeconds}s)',
                      isLoading: state.isSendingCode,
                      onSendCode: () async {
                        notifier.updateEmail(emailController.text);
                        if (!notifier.validateEmailOnly(
                          emailRequired:
                              l10n?.authEmailRequiredError ??
                              'Please enter your email.',
                        )) {
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
                        await notifier.sendCode();
                      },
                    )
                    .animate(key: const ValueKey('code-field-anim'))
                    .fadeIn(duration: 160.ms, curve: Curves.easeOutCubic)
                    .slideX(
                      begin: 0.02,
                      end: 0,
                      duration: 160.ms,
                      curve: Curves.easeOutCubic,
                    ),
                AuthFieldError(state.codeError),
              ],
            ),
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AuthStatusMessage(error: state.errorMessage),
          ],
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            key: const Key('auth-login-submit-action'),
            label: l10n?.authSignIn ?? 'Sign in',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(emailController.text);
              notifier.updatePassword(passwordController.text);
              notifier.updateCode(codeController.text);
              final isValid = notifier.validate(
                emailRequired:
                    l10n?.authEmailRequiredError ?? 'Please enter your email.',
                emailInvalid:
                    l10n?.authEmailInvalidError ??
                    'Please enter a valid email address.',
                passwordRequired:
                    l10n?.authPasswordRequiredError ??
                    'Please enter your password.',
                codeRequired:
                    l10n?.authCodeRequiredError ??
                    'Please enter the verification code.',
              );
              if (!isValid) return;
              final session = await notifier.submit();
              if (session != null && context.mounted) goAfterLogin();
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
            callbackController: wechatCallbackController,
            isStarting: state.isStartingWechatLogin,
            isCompleting: state.isCompletingWechatLogin,
            authorizeUrl: state.wechatAuthorizeUrl,
            onStart: () => startWechatLogin(context, l10n),
            onComplete: () => completeWechatLoginFromInput(context, l10n),
          ),
          _QqOAuthPanel(
            callbackController: qqCallbackController,
            isStarting: state.isStartingQqLogin,
            isCompleting: state.isCompletingQqLogin,
            authorizeUrl: state.qqAuthorizeUrl,
            onStart: () => startQqLogin(context, l10n),
            onComplete: () => completeQqLoginFromInput(context, l10n),
          ),
          _AppleOAuthPanel(
            isLoading: state.isStartingAppleLogin,
            onSignIn: startAppleLogin,
          ),
        ],
      ),
    );
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
            prefix: const Icon(Icons.link),
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

class _QqOAuthPanel extends StatelessWidget {
  const _QqOAuthPanel({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacingTokens.md),
        OutlinedButton.icon(
          key: const Key('qq-login-start-button'),
          onPressed: isStarting || isCompleting ? null : onStart,
          icon: isStarting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.qr_code_rounded, size: 18),
          label: const Text('Sign in with QQ'),
        ),
        if (authorizeUrl?.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacingTokens.md),
          AuthTextField(
            key: const Key('qq-callback-input'),
            controller: callbackController,
            label: 'QQ callback link / code',
            hint: 'Paste the callback URL after authorization',
            keyboardType: TextInputType.url,
            prefix: const Icon(Icons.link),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AuthPrimaryButton(
            label: 'Complete QQ sign-in',
            isLoading: isCompleting,
            onPressed: onComplete,
          ),
        ],
      ],
    );
  }
}

class _AppleOAuthPanel extends StatefulWidget {
  const _AppleOAuthPanel({required this.isLoading, required this.onSignIn});

  final bool isLoading;
  final VoidCallback onSignIn;

  @override
  State<_AppleOAuthPanel> createState() => _AppleOAuthPanelState();
}

class _AppleOAuthPanelState extends State<_AppleOAuthPanel> {
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final available = await SignInWithApple.isAvailable();
    if (mounted) {
      setState(() => _isAvailable = available);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacingTokens.md),
      child: AbsorbPointer(
        absorbing: widget.isLoading,
        child: SignInWithAppleButton(onPressed: widget.onSignIn),
      ),
    );
  }
}
