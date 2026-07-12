import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/presentation/providers/forms/login_form_provider.dart';
import 'package:luminous/features/auth/presentation/providers/oauth_login.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_callback_parser.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_panels.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/shell.dart';
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
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final codeController = useTextEditingController();
    final wechatCallbackController = useTextEditingController();
    final qqCallbackController = useTextEditingController();

    final state = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    final oauthState = ref.watch(oauthLoginProvider);
    final oauthController = ref.read(oauthLoginProvider.notifier);
    final l10n = AppLocalizations.of(context);

    // ---- navigation helpers ----

    String? safeReturnTo(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return null;
      if (!trimmed.startsWith('/') || trimmed.startsWith('//')) return null;
      if (trimmed == AppRoutes.login ||
          trimmed.startsWith('${AppRoutes.login}?') ||
          trimmed.startsWith('${AppRoutes.login}/')) {
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
      if (fallbackHome) context.go(AppRoutes.home);
    }

    String? webWechatCallbackUri() {
      if (!kIsWeb) return null;
      final base = Uri.base;
      final rt = safeReturnTo(returnTo);
      return Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: AppRoutes.loginOauthWechat,
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
        path: AppRoutes.loginOauthQq,
        queryParameters: rt == null ? null : {'returnTo': rt},
      ).toString();
    }

    // ---- OAuth action handlers ----

    Future<void> startWechatLogin() async {
      final attempt = await oauthController.startWechatLogin(
        webCallbackUri: webWechatCallbackUri(),
      );
      if (!context.mounted) return;

      switch (attempt) {
        case WechatLoginCompleted():
          goAfterLogin(fallbackHome: true);
        case WechatLoginWebFallback(:final authorizeUrl):
          final opened = await ref
              .read(externalUrlLauncherProvider)
              .open(Uri.parse(authorizeUrl));
          if (!context.mounted) return;
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
        case WechatLoginFailed():
          // Error is in oauthState.errorMessage — toast is shown via state
          break;
      }
    }

    Future<void> completeWechatLoginFromInput() async {
      final callback = OAuthCallbackParser.parse(
        wechatCallbackController.text,
        oauthState.wechatState,
      );
      if (callback == null) {
        final message = wechatCallbackController.text.trim().isEmpty
            ? l10n?.authWechatCallbackRequiredToast ??
                  'Paste the WeChat callback link first.'
            : l10n?.authWechatCallbackInvalidToast ??
                  'The WeChat callback link is missing code or state.';
        await AppToast.show(context, message);
        return;
      }
      final session = await oauthController.completeWechatLogin(
        code: callback.code,
        state: callback.state,
      );
      if (session == null || !context.mounted) return;
      goAfterLogin(fallbackHome: true);
    }

    Future<void> startQqLogin() async {
      final authorizeUrl = await oauthController.startQqLogin(
        webCallbackUri: webQqCallbackUri(),
      );
      if (authorizeUrl == null || !context.mounted) return;

      final opened = await ref
          .read(externalUrlLauncherProvider)
          .open(Uri.parse(authorizeUrl));
      if (!context.mounted) return;
      if (!opened) {
        await AppToast.show(
          context,
          l10n?.authWechatBrowserOpenFailed ??
              'Could not open the QQ authorization page.',
        );
        return;
      }
      await AppToast.show(context, 'QQ authorization opened in your browser.');
    }

    Future<void> completeQqLoginFromInput() async {
      final callback = OAuthCallbackParser.parse(
        qqCallbackController.text,
        oauthState.qqState,
      );
      if (callback == null) {
        final message = qqCallbackController.text.trim().isEmpty
            ? 'Please paste the QQ callback link first.'
            : 'The QQ callback link is missing code or state.';
        await AppToast.show(context, message);
        return;
      }
      final session = await oauthController.completeQqLogin(
        code: callback.code,
        state: callback.state,
      );
      if (session == null || !context.mounted) return;
      goAfterLogin(fallbackHome: true);
    }

    Future<void> startAppleLogin() async {
      if (!context.mounted) return;
      final failMessage =
          l10n?.authWechatBrowserOpenFailed ?? 'Apple Sign In failed.';
      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        if (!context.mounted) return;
        final session = await oauthController.loginWithApple(
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

    // Handle OAuth callbacks on first build (deep-link from browser redirect)
    useEffect(() {
      if ((wechatCode?.isNotEmpty ?? false) &&
          (wechatState?.isNotEmpty ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          oauthController
              .completeWechatLogin(code: wechatCode!, state: wechatState!)
              .then((s) {
                if (s != null && context.mounted) {
                  goAfterLogin(fallbackHome: true);
                }
              });
        });
      }
      if ((qqCode?.isNotEmpty ?? false) && (qqState?.isNotEmpty ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          oauthController.completeQqLogin(code: qqCode!, state: qqState!).then((
            s,
          ) {
            if (s != null && context.mounted) {
              goAfterLogin(fallbackHome: true);
            }
          });
        });
      }
      return null;
    }, []);

    // ---- build UI ----

    return AuthShell(
      title: l10n?.authWelcomeBack ?? 'Welcome back',
      subtitle: l10n?.authLoginSubtitle,
      logo: const AuthBrandLogo(),
      leading: const AppBackButton(fallbackRoute: AppRoutes.home),
      centerTitle: true,
      formModeSelector: FTabs(
        key: const ValueKey('auth-login-mode-tabs'),
        control: FTabControl.lifted(
          index: state.mode.index,
          onChange: (index) => notifier.updateMode(AuthLoginMode.values[index]),
        ),
        children: [
          FTabEntry(
            label: Text(l10n?.authModePassword ?? 'Password'),
            child: const SizedBox.shrink(),
          ),
          FTabEntry(
            label: Text(l10n?.authModeCode ?? 'Code'),
            child: const SizedBox.shrink(),
          ),
        ],
      ),
      form: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FTextFormField.email(
              key: const Key('auth-login-email-field'),
              control: FTextFieldControl.managed(controller: emailController),
              label: Text(l10n?.authEmailLabel ?? 'Email'),
              hint: l10n?.authEmailHint ?? 'name@example.com',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => EmailInput.validate(
                value,
                requiredMessage:
                    l10n?.authEmailRequiredError ?? 'Please enter your email.',
                invalidMessage:
                    l10n?.authEmailInvalidError ??
                    'Please enter a valid email address.',
              ),
            ),
            const SizedBox(height: Spacing.level4),
            if (state.mode == AuthLoginMode.password)
              FTextFormField.password(
                key: const ValueKey('password-login-field'),
                control: FTextFieldControl.managed(
                  controller: passwordController,
                ),
                label: Text(l10n?.authPasswordLabel ?? 'Password'),
                hint:
                    l10n?.authPasswordHint ??
                    'At least 8 characters, ideally with mixed case and numbers',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => RequiredInput.validate(
                  value,
                  l10n?.authPasswordRequiredError ??
                      'Please enter your password.',
                ),
              )
            else
              VerificationCodeField(
                fieldKey: const ValueKey('auth-login-code-field'),
                controller: codeController,
                label: l10n?.authCodeLabel ?? 'Verification code',
                hint: l10n?.authCodeLabel ?? 'Verification code',
                buttonLabel: state.cooldownSeconds == null
                    ? l10n?.authSendCode ?? 'Send code'
                    : l10n?.authSendCodeAgain(state.cooldownSeconds!) ??
                          'Send again (${state.cooldownSeconds}s)',
                isLoading: state.isSendingCode,
                validator: (value) => RequiredInput.validate(
                  value,
                  l10n?.authCodeRequiredError ??
                      'Please enter the verification code.',
                ),
                onSendCode: () async {
                  final emailError = EmailInput.validate(
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
            if ((state.errorMessage?.isNotEmpty ?? false) ||
                (oauthState.errorMessage?.isNotEmpty ?? false)) ...[
              const SizedBox(height: Spacing.level4),
              FToast(
                variant: FToastVariant.destructive,
                title: Text(
                  state.errorMessage?.isNotEmpty == true
                      ? state.errorMessage!
                      : oauthState.errorMessage!,
                ),
              ),
            ],
            const SizedBox(height: Spacing.level6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  key: const Key('auth-login-submit-action'),
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: state.isSubmitting
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          notifier.updateEmail(emailController.text);
                          notifier.updatePassword(passwordController.text);
                          notifier.updateCode(codeController.text);
                          final session = await notifier.submit();
                          if (session != null && context.mounted) {
                            goAfterLogin();
                          }
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: FCircularProgress(),
                        )
                      : Text(l10n?.authSignIn ?? 'Sign in'),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Spacing.level2,
              runSpacing: Spacing.level1,
              children: [
                Text(
                  l10n?.authNeedAccountPrompt ?? 'Need an account?',
                  style: TypographyToken.level2
                      .body(context)
                      .copyWith(color: context.theme.colors.mutedForeground),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => context.push(AppRoutes.register),
                  child: Text(
                    l10n?.authRegisterNowAction ?? 'Register now',
                    style: TypographyToken.level2.body(context),
                  ),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => context.push(AppRoutes.forgotPassword),
                  child: Text(
                    l10n?.authForgotPasswordPrompt ?? 'Forgot your password?',
                    style: TypographyToken.level2.body(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level5),
            WechatOAuthPanel(
              callbackController: wechatCallbackController,
              isStarting: oauthState.isStartingWechat,
              isCompleting: oauthState.isCompletingWechat,
              authorizeUrl: oauthState.wechatAuthorizeUrl,
              onStart: startWechatLogin,
              onComplete: completeWechatLoginFromInput,
            ),
            QqOAuthPanel(
              callbackController: qqCallbackController,
              isStarting: oauthState.isStartingQq,
              isCompleting: oauthState.isCompletingQq,
              authorizeUrl: oauthState.qqAuthorizeUrl,
              onStart: startQqLogin,
              onComplete: completeQqLoginFromInput,
            ),
            AppleOAuthPanel(
              isLoading: oauthState.isStartingApple,
              onSignIn: startAppleLogin,
            ),
          ],
        ),
      ),
    );
  }
}
