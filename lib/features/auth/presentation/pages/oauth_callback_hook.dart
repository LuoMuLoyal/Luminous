import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/features/auth/presentation/pages/oauth_navigation.dart';
import 'package:luminous/features/auth/presentation/providers/oauth_login.dart';

/// Handles OAuth deep-link callbacks on first build (when the browser
/// redirects back with code/state query parameters).
///
/// Must be called unconditionally from [LoginPage]'s build method to
/// preserve hook ordering.
void useOAuthCallbackHandler({
  required BuildContext context,
  required WidgetRef ref,
  required OAuthLoginController oauthController,
  required String? wechatCode,
  required String? wechatState,
  required String? qqCode,
  required String? qqState,
  required String? weiboCode,
  required String? weiboState,
  required String? googleCode,
  required String? googleState,
  required String? returnTo,
}) {
  useEffect(() {
    if ((wechatCode?.isNotEmpty ?? false) &&
        (wechatState?.isNotEmpty ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          oauthController
              .completeWechatLogin(code: wechatCode!, state: wechatState!)
              .then((s) {
                if (s != null && context.mounted) {
                  goAfterLogin(context, returnTo: returnTo, fallbackHome: true);
                }
              }),
        );
      });
    }
    if ((qqCode?.isNotEmpty ?? false) && (qqState?.isNotEmpty ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          oauthController.completeQqLogin(code: qqCode!, state: qqState!).then((
            s,
          ) {
            if (s != null && context.mounted) {
              goAfterLogin(context, returnTo: returnTo, fallbackHome: true);
            }
          }),
        );
      });
    }
    if ((weiboCode?.isNotEmpty ?? false) && (weiboState?.isNotEmpty ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          oauthController
              .completeWeiboLogin(code: weiboCode!, state: weiboState!)
              .then((s) {
                if (s != null && context.mounted) {
                  goAfterLogin(context, returnTo: returnTo, fallbackHome: true);
                }
              }),
        );
      });
    }
    if ((googleCode?.isNotEmpty ?? false) &&
        (googleState?.isNotEmpty ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          oauthController
              .completeGoogleLogin(code: googleCode!, state: googleState!)
              .then((s) {
                if (s != null && context.mounted) {
                  goAfterLogin(context, returnTo: returnTo, fallbackHome: true);
                }
              }),
        );
      });
    }
    return null;
  }, []);
}
