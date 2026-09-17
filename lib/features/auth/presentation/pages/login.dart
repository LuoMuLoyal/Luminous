import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/widgets/common/control/back_button.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/auth/presentation/pages/oauth_callback_hook.dart';
import 'package:luminous/features/auth/presentation/pages/oauth_handlers.dart';
import 'package:luminous/features/auth/presentation/pages/oauth_navigation.dart';
import 'package:luminous/features/auth/presentation/providers/forms/login.dart';
import 'package:luminous/features/auth/presentation/providers/oauth_login.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/auth_scroll_body.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/branding.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_panels.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/verification_code_field.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({
    super.key,
    this.wechatCode,
    this.wechatState,
    this.qqCode,
    this.qqState,
    this.weiboCode,
    this.weiboState,
    this.googleCode,
    this.googleState,
    this.returnTo,
  });

  final String? wechatCode;
  final String? wechatState;
  final String? qqCode;
  final String? qqState;
  final String? weiboCode;
  final String? weiboState;
  final String? googleCode;
  final String? googleState;
  final String? returnTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final codeController = useTextEditingController();
    final wechatCallbackController = useTextEditingController();
    final qqCallbackController = useTextEditingController();
    final weiboCallbackController = useTextEditingController();
    final googleCallbackController = useTextEditingController();

    final state = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    final oauthState = ref.watch(oauthLoginProvider);
    final oauthController = ref.read(oauthLoginProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    // Handle OAuth callbacks on first build (deep-link from browser redirect)
    useOAuthCallbackHandler(
      context: context,
      ref: ref,
      oauthController: oauthController,
      wechatCode: wechatCode,
      wechatState: wechatState,
      qqCode: qqCode,
      qqState: qqState,
      weiboCode: weiboCode,
      weiboState: weiboState,
      googleCode: googleCode,
      googleState: googleState,
      returnTo: returnTo,
    );

    // ---- build UI ----

    return PageScaffold(
      title: l10n.authWelcomeBack,
      leading: const AppBackButton(fallbackRoute: Routes.home),
      child: AuthScrollBody(
        children: [
          const Center(child: AuthBrandLogo()),
          const SizedBox(height: Spacing.lg),
          Text(
            l10n.authLoginSubtitle,
            textAlign: TextAlign.center,
            style: context.theme.typography.body.md.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
          const SizedBox(height: Spacing.xl2),
          FTabs(
            key: const ValueKey('auth-login-mode-tabs'),
            control: FTabControl.lifted(
              index: state.mode.index,
              onChange: (index) =>
                  notifier.updateMode(AuthLoginMode.values[index]),
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
          const SizedBox(height: Spacing.xl2),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FTextFormField.email(
                  key: const Key('auth-login-email-field'),
                  control: FTextFieldControl.managed(
                    controller: emailController,
                  ),
                  label: Text(l10n.authEmailLabel),
                  hint: l10n.authEmailHint,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => EmailInput.validate(
                    value,
                    requiredMessage: l10n.authEmailRequiredError,
                    invalidMessage: l10n.authEmailInvalidError,
                  ),
                ),
                const SizedBox(height: Spacing.lg),
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
                    validator: (value) => RequiredInput.validate(
                      value,
                      l10n.authCodeRequiredError,
                    ),
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
                              final msg = ref
                                  .read(loginFormProvider)
                                  .errorMessage;
                              if (msg != null && msg.isNotEmpty) {
                                await Toast.show(context, msg);
                              }
                            }
                          },
                  ),
                const SizedBox(height: Spacing.xl2),
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
                              final msg =
                                  formState.errorMessage?.isNotEmpty == true
                                  ? formState.errorMessage!
                                  : oauth.errorMessage?.isNotEmpty == true
                                  ? oauth.errorMessage!
                                  : null;
                              if (msg != null) {
                                await Toast.show(context, msg);
                              }
                            }
                            if (session != null && context.mounted) {
                              // `fallbackHome` matters: sign-out and the
                              // "go to login" links land on a bare `/login`
                              // with no `return-to`, and without the fallback
                              // this call would be a silent no-op, leaving the
                              // user on the login page while already signed in.
                              goAfterLogin(
                                context,
                                returnTo: returnTo,
                                fallbackHome: true,
                              );
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
                const SizedBox(height: Spacing.lg),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: [
                    // Group: "需要账号？" + "立即注册"
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: Spacing.sm,
                      children: [
                        Text(
                          l10n.authNeedAccountPrompt,
                          style: typography.body.xs2.copyWith(
                            color: SemanticColor.neutral.solid(context),
                          ),
                        ),
                        FButton(
                          variant: FButtonVariant.ghost,
                          size: FButtonSizeVariant.sm,
                          mainAxisSize: MainAxisSize.min,
                          onPress: () => context.push(Routes.register),
                          child: Text(
                            l10n.authRegisterNowAction,
                            style: typography.body.xs2,
                          ),
                        ),
                      ],
                    ),
                    // "忘记密码"
                    FButton(
                      variant: FButtonVariant.ghost,
                      size: FButtonSizeVariant.sm,
                      mainAxisSize: MainAxisSize.min,
                      onPress: () => context.push(Routes.forgotPassword),
                      child: Text(
                        l10n.authForgotPasswordPrompt,
                        style: typography.body.xs2,
                      ),
                    ),
                  ],
                ),
                // Terms notice — passive, non-blocking.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: Spacing.xs,
                    runSpacing: Spacing.xs,
                    children: [
                      Text(
                        l10n.authLoginTermsAgreementPrefix,
                        style: typography.body.xs2.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                      FButton(
                        variant: FButtonVariant.ghost,
                        size: FButtonSizeVariant.sm,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => context.push('${Routes.legal}/terms'),
                        child: Text(
                          l10n.authTermsOfService,
                          style: typography.body.xs2.copyWith(
                            color: SemanticColor.primary.solid(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        l10n.authTermsConjunction,
                        style: typography.body.xs2.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                      FButton(
                        variant: FButtonVariant.ghost,
                        size: FButtonSizeVariant.sm,
                        mainAxisSize: MainAxisSize.min,
                        onPress: () => context.push('${Routes.legal}/privacy'),
                        child: Text(
                          l10n.authPrivacyPolicy,
                          style: typography.body.xs2.copyWith(
                            color: SemanticColor.primary.solid(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                OAuthButtonRow(
                  // WeChat/Weibo 入口暂隐藏（保留底层流程，见 docs/TODO.md）。
                  showWechat: false,
                  showWeibo: false,
                  wechatCallbackController: wechatCallbackController,
                  isStartingWechat: oauthState.isStartingWechat,
                  isCompletingWechat: oauthState.isCompletingWechat,
                  wechatAuthorizeUrl: oauthState.wechatAuthorizeUrl,
                  onWechatStart: () => startWechatLogin(
                    context,
                    ref,
                    oauthController,
                    l10n,
                    returnTo: returnTo,
                  ),
                  onWechatComplete: () => completeWechatLoginFromInput(
                    context,
                    oauthController,
                    l10n,
                    callbackController: wechatCallbackController,
                    fallbackState: oauthState.wechatState,
                    returnTo: returnTo,
                  ),
                  qqCallbackController: qqCallbackController,
                  isStartingQq: oauthState.isStartingQq,
                  isCompletingQq: oauthState.isCompletingQq,
                  qqAuthorizeUrl: oauthState.qqAuthorizeUrl,
                  onQqStart: () => startQqLogin(
                    context,
                    ref,
                    oauthController,
                    l10n,
                    returnTo: returnTo,
                  ),
                  onQqComplete: () => completeQqLoginFromInput(
                    context,
                    oauthController,
                    l10n,
                    callbackController: qqCallbackController,
                    fallbackState: oauthState.qqState,
                    returnTo: returnTo,
                  ),
                  weiboCallbackController: weiboCallbackController,
                  isStartingWeibo: oauthState.isStartingWeibo,
                  isCompletingWeibo: oauthState.isCompletingWeibo,
                  weiboAuthorizeUrl: oauthState.weiboAuthorizeUrl,
                  onWeiboStart: () => startWeiboLogin(
                    context,
                    ref,
                    oauthController,
                    l10n,
                    returnTo: returnTo,
                  ),
                  onWeiboComplete: () => completeWeiboLoginFromInput(
                    context,
                    oauthController,
                    l10n,
                    callbackController: weiboCallbackController,
                    fallbackState: oauthState.weiboState,
                    returnTo: returnTo,
                  ),
                  googleCallbackController: googleCallbackController,
                  isStartingGoogle: oauthState.isStartingGoogle,
                  isCompletingGoogle: oauthState.isCompletingGoogle,
                  googleAuthorizeUrl: oauthState.googleAuthorizeUrl,
                  onGoogleStart: () => startGoogleLogin(
                    context,
                    ref,
                    oauthController,
                    l10n,
                    returnTo: returnTo,
                  ),
                  onGoogleComplete: () => completeGoogleLoginFromInput(
                    context,
                    oauthController,
                    l10n,
                    callbackController: googleCallbackController,
                    fallbackState: oauthState.googleState,
                    returnTo: returnTo,
                  ),
                  isStartingApple: oauthState.isStartingApple,
                  onAppleSignIn: () => startAppleLogin(
                    context,
                    ref,
                    oauthController,
                    l10n,
                    returnTo: returnTo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
