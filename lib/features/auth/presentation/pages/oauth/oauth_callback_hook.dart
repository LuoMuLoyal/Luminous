import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/session_snapshot.dart';
import 'package:luminous/core/router/deep_link.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/pages/oauth/oauth_navigation.dart';
import 'package:luminous/features/auth/presentation/providers/oauth_login.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_deep_link.dart';

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
  required String? googleCode,
  required String? googleState,
  required String? returnTo,
}) {
  useEffect(() {
    void complete(
      Future<AuthSession?> Function() call, {
      required String? target,
    }) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          call().then((s) {
            if (s != null && context.mounted) {
              goAfterLogin(context, returnTo: target, fallbackHome: true);
            }
          }),
        );
      });
    }

    if ((wechatCode?.isNotEmpty ?? false) &&
        (wechatState?.isNotEmpty ?? false)) {
      complete(
        () => oauthController.completeWechatLogin(
          code: wechatCode!,
          state: wechatState!,
        ),
        target: returnTo,
      );
    }
    if ((qqCode?.isNotEmpty ?? false) && (qqState?.isNotEmpty ?? false)) {
      complete(
        () => oauthController.completeQqLogin(code: qqCode!, state: qqState!),
        target: returnTo,
      );
    }
    if ((googleCode?.isNotEmpty ?? false) &&
        (googleState?.isNotEmpty ?? false)) {
      complete(
        () => oauthController.completeGoogleLogin(
          code: googleCode!,
          state: googleState!,
        ),
        target: returnTo,
      );
    }
    return null;
  }, []);

  useOAuthDeepLinkHandler(
    context: context,
    ref: ref,
    oauthController: oauthController,
  );
}

/// Consumes native deep-link OAuth callbacks while [LoginPage] is mounted.
///
/// Split from [useOAuthCallbackHandler] so the query-parameter path (web) and
/// the deep-link path (native) stay independently readable, while both converge
/// on the same `complete*Login` calls.
///
/// Deep links are held until `authSessionProvider` finishes restoring
/// (`isLoading == false`). Otherwise the router redirect guard can navigate
/// away from `/login` before the code is exchanged, and the callback is
/// swallowed.
void useOAuthDeepLinkHandler({
  required BuildContext context,
  required WidgetRef ref,
  required OAuthLoginController oauthController,
}) {
  useEffect(() {
    // Buffers a link that arrived while the session was still restoring.
    OAuthDeepLink? pending;

    void dispatch(OAuthDeepLink link) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        final future = switch (link.provider) {
          OAuthDeepLinkProvider.wechat => oauthController.completeWechatLogin(
            code: link.code,
            state: link.state,
          ),
          OAuthDeepLinkProvider.qq => oauthController.completeQqLogin(
            code: link.code,
            state: link.state,
          ),
          OAuthDeepLinkProvider.google => oauthController.completeGoogleLogin(
            code: link.code,
            state: link.state,
          ),
        };

        unawaited(
          future.then((s) {
            if (s != null && context.mounted) {
              goAfterLogin(
                context,
                returnTo: link.returnTo,
                fallbackHome: true,
              );
            }
          }),
        );
      });
    }

    void onUri(Uri uri) {
      final link = parseOAuthDeepLink(uri);
      if (link == null) return;

      // Wait for session restore before consuming, else the redirect guard
      // wins the race and the callback is dropped.
      if (ref.read(authSessionProvider).isLoading) {
        pending = link;
        return;
      }
      dispatch(link);
    }

    // Riverpod 3 exposes stream providers as `AsyncValue<Uri>`; only distinct
    // non-null values are dispatched.
    final linkSubscription = ref.listenManual<AsyncValue<Uri>>(
      deepLinkStreamProvider,
      (_, next) {
        final uri = next.value;
        if (uri != null) onUri(uri);
      },
      fireImmediately: true,
    );

    // Flush a link buffered during restore.
    final sessionSubscription = ref.listenManual(authSessionProvider, (
      _,
      next,
    ) {
      if (next.isLoading) return;
      final link = pending;
      if (link == null) return;
      pending = null;
      dispatch(link);
    });

    return () {
      linkSubscription.close();
      sessionSubscription.close();
    };
  }, []);
}
