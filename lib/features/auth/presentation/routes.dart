import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router/helpers.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings.dart';
import 'package:luminous/features/auth/presentation/pages/change_email.dart';
import 'package:luminous/features/auth/presentation/pages/forgot_password.dart';
import 'package:luminous/features/auth/presentation/pages/login.dart';
import 'package:luminous/features/auth/presentation/pages/register.dart';

part 'routes.g.dart';

// -- Auth routes --

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute({this.returnTo});

  final String? returnTo;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return fadePage(
      key: state.pageKey,
      child: LoginPage(returnTo: returnTo),
    );
  }
}

@TypedGoRoute<LoginOauthWechatRoute>(path: '/login/oauth/wechat')
class LoginOauthWechatRoute extends GoRouteData with $LoginOauthWechatRoute {
  const LoginOauthWechatRoute({this.code, this.state, this.returnTo});

  final String? code;

  final String? state;

  final String? returnTo;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return fadePage(
      key: state.pageKey,
      child: LoginPage(
        wechatCode: code,
        wechatState: this.state,
        returnTo: returnTo,
      ),
    );
  }
}

@TypedGoRoute<LoginOauthQqRoute>(path: '/login/oauth/qq')
class LoginOauthQqRoute extends GoRouteData with $LoginOauthQqRoute {
  const LoginOauthQqRoute({this.code, this.state, this.returnTo});

  final String? code;

  final String? state;

  final String? returnTo;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return fadePage(
      key: state.pageKey,
      child: LoginPage(qqCode: code, qqState: this.state, returnTo: returnTo),
    );
  }
}

@TypedGoRoute<ForgotPasswordRoute>(path: '/forgot-password')
class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  const ForgotPasswordRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return fadePage(key: state.pageKey, child: const ForgotPasswordPage());
  }
}

@TypedGoRoute<RegisterRoute>(path: '/register')
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return fadePage(key: state.pageKey, child: const RegisterPage());
  }
}

// -- Account routes --

@TypedGoRoute<AccountRoute>(path: '/account')
class AccountRoute extends GoRouteData with $AccountRoute {
  const AccountRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const AccountSettingsPage());
  }
}

@TypedGoRoute<AccountOauthWechatRoute>(path: '/account/oauth/wechat')
class AccountOauthWechatRoute extends GoRouteData
    with $AccountOauthWechatRoute {
  const AccountOauthWechatRoute({this.code, this.state});

  final String? code;

  final String? state;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: AccountSettingsPage(wechatCode: code, wechatState: this.state),
    );
  }
}

@TypedGoRoute<AccountChangeEmailRoute>(path: '/account/change-email')
class AccountChangeEmailRoute extends GoRouteData
    with $AccountChangeEmailRoute {
  const AccountChangeEmailRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const ChangeEmailPage());
  }
}
