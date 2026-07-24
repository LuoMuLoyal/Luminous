import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/features/auth/presentation/providers/forms/login.dart';
import 'package:luminous/features/auth/presentation/providers/oauth_login.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/branding.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_callback_parser.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_panels.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/shell.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/verification_code_field.dart';
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
    final l10n = AppLocalizations.of(context)!;

    // ---- navigation helpers ----

    String? safeReturnTo(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return null;
      if (!trimmed.startsWith('/') || trimmed.startsWith('//')) return null;
      if (trimmed == Routes.login ||
          trimmed.startsWith('${Routes.login}?') ||
          trimmed.startsWith('${Routes.login}/')) {
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
      if (fallbackHome) context.go(Routes.home);
    }

    String? webWechatCallbackUri() {
      if (!kIsWeb) return null;
      final base = Uri.base;
      final rt = safeReturnTo(returnTo);
      return Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: Routes.loginOauthWechat,
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
        path: Routes.loginOauthQq,
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
            await Toast.show(context, l10n.authWechatBrowserOpenFailed);
            return;
          }
          await Toast.show(context, l10n.authWechatAuthorizeOpened);
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
            ? l10n.authWechatCallbackRequiredToast
            : l10n.authWechatCallbackInvalidToast;
        await Toast.show(context, message);
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
        await Toast.show(context, l10n.authQqBrowserOpenFailed);
        return;
      }
      await Toast.show(context, l10n.authQqAuthorizeOpened);
    }

    Future<void> completeQqLoginFromInput() async {
      final callback = OAuthCallbackParser.parse(
        qqCallbackController.text,
        oauthState.qqState,
      );
      if (callback == null) {
        final message = qqCallbackController.text.trim().isEmpty
            ? l10n.authQqCallbackRequiredToast
            : l10n.authQqCallbackInvalidToast;
        await Toast.show(context, message);
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
      final failMessage = l10n.authAppleSignInFailed;
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
        if (context.mounted) await Toast.show(context, failMessage);
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
      title: l10n.authWelcomeBack,
      subtitle: l10n.authLoginSubtitle,
      logo: const AuthBrandLogo(),
      leading: const AppBackButton(fallbackRoute: Routes.home),
      centerTitle: true,
      formModeSelector: FTabs(
        key: const ValueKey('auth-login-mode-tabs'),
        control: FTabControl.lifted(
          index: state.mode.index,
          onChange: (index) => notifier.updateMode(AuthLoginMode.values[index]),
        ),
        children: [
          FTabEntry(
            label: Text(l10n.authModePassword),
            child: const SizedBox.shrink(),
          ),
          FTabEntry(
            label: Text(l10n.authModeCode),
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
            if (state.mode == AuthLoginMode.password)
              FTextFormField.password(
                key: const ValueKey('password-login-field'),
                control: FTextFieldControl.managed(
                  controller: passwordController,
                ),
                label: Text(l10n.authPasswordLabel),
                hint: l10n.authPasswordLoginHint,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => RequiredInput.validate(
                  value,
                  l10n.authPasswordRequiredError,
                ),
              )
            else
              VerificationCodeField(
                fieldKey: const ValueKey('auth-login-code-field'),
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
                    (state.cooldownSeconds != null &&
                        state.cooldownSeconds! > 0)
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
                          final msg = ref.read(loginFormProvider).errorMessage;
                          if (msg != null && msg.isNotEmpty) {
                            await Toast.show(context, msg);
                          }
                        }
                      },
              ),
            const SizedBox(height: Spacing.level6),
            SizedBox(
              width: double.infinity,
              child: FButton(
                key: const Key('auth-login-submit-action'),
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
                        if (session == null && context.mounted) {
                          final formState = ref.read(loginFormProvider);
                          final oauth = ref.read(oauthLoginProvider);
                          final msg = formState.errorMessage?.isNotEmpty == true
                              ? formState.errorMessage!
                              : oauth.errorMessage?.isNotEmpty == true
                              ? oauth.errorMessage!
                              : null;
                          if (msg != null) {
                            await Toast.show(context, msg);
                          }
                        }
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
                    : Text(l10n.authSignIn),
              ),
            ),
            const SizedBox(height: Spacing.level4),
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Spacing.level2,
              runSpacing: Spacing.level1,
              children: [
                Text(
                  l10n.authNeedAccountPrompt,
                  style: TypographyToken.level2
                      .body(context)
                      .copyWith(color: context.theme.colors.mutedForeground),
                ),
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => context.push(Routes.register),
                  child: Text(
                    l10n.authRegisterNowAction,
                    style: TypographyToken.level2.body(context),
                  ),
                ),
              ],
            ),
            FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: () => context.push(Routes.forgotPassword),
              child: Text(
                l10n.authForgotPasswordPrompt,
                style: TypographyToken.level2.body(context),
              ),
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
