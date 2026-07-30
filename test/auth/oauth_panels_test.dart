import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_panels.dart';

import '../helpers/test_forui_app.dart';

/// Helper to build an [OAuthButtonRow] with dummy values for the
/// providers not under test.
OAuthButtonRow _buildRow({
  required TextEditingController wechatCallbackController,
  required bool isStartingWechat,
  required bool isCompletingWechat,
  required String? wechatAuthorizeUrl,
  required VoidCallback onWechatStart,
  required VoidCallback onWechatComplete,
  required TextEditingController qqCallbackController,
  required bool isStartingQq,
  required bool isCompletingQq,
  required String? qqAuthorizeUrl,
  required VoidCallback onQqStart,
  required VoidCallback onQqComplete,
  required TextEditingController weiboCallbackController,
  required bool isStartingWeibo,
  required bool isCompletingWeibo,
  required String? weiboAuthorizeUrl,
  required VoidCallback onWeiboStart,
  required VoidCallback onWeiboComplete,
  required TextEditingController googleCallbackController,
  required bool isStartingGoogle,
  required bool isCompletingGoogle,
  required String? googleAuthorizeUrl,
  required VoidCallback onGoogleStart,
  required VoidCallback onGoogleComplete,
  required bool isStartingApple,
  required VoidCallback onAppleSignIn,
}) {
  return OAuthButtonRow(
    wechatCallbackController: wechatCallbackController,
    isStartingWechat: isStartingWechat,
    isCompletingWechat: isCompletingWechat,
    wechatAuthorizeUrl: wechatAuthorizeUrl,
    onWechatStart: onWechatStart,
    onWechatComplete: onWechatComplete,
    qqCallbackController: qqCallbackController,
    isStartingQq: isStartingQq,
    isCompletingQq: isCompletingQq,
    qqAuthorizeUrl: qqAuthorizeUrl,
    onQqStart: onQqStart,
    onQqComplete: onQqComplete,
    weiboCallbackController: weiboCallbackController,
    isStartingWeibo: isStartingWeibo,
    isCompletingWeibo: isCompletingWeibo,
    weiboAuthorizeUrl: weiboAuthorizeUrl,
    onWeiboStart: onWeiboStart,
    onWeiboComplete: onWeiboComplete,
    googleCallbackController: googleCallbackController,
    isStartingGoogle: isStartingGoogle,
    isCompletingGoogle: isCompletingGoogle,
    googleAuthorizeUrl: googleAuthorizeUrl,
    onGoogleStart: onGoogleStart,
    onGoogleComplete: onGoogleComplete,
    isStartingApple: isStartingApple,
    onAppleSignIn: onAppleSignIn,
  );
}

void main() {
  group('OAuthButtonRow — WeChat', () {
    testWidgets('renders start button when not loading', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('wechat-login-start-button')),
        findsOneWidget,
      );
    });

    testWidgets('start button disabled when isStarting', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: true,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<GestureDetector>(
        find.byKey(const Key('wechat-login-start-button')),
      );
      expect(button.onTap, isNull);
    });

    testWidgets('start button disabled when isCompleting', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: true,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<GestureDetector>(
        find.byKey(const Key('wechat-login-start-button')),
      );
      expect(button.onTap, isNull);
    });

    testWidgets('shows callback input when authorizeUrl is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl:
                  'https://open.weixin.qq.com/connect/oauth2/authorize',
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('wechat-callback-input')), findsOneWidget);
    });

    testWidgets('hides callback input when authorizeUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('wechat-callback-input')), findsNothing);
    });

    testWidgets('hides callback input when authorizeUrl is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: '',
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('wechat-callback-input')), findsNothing);
    });

    testWidgets('complete button disabled when isCompleting', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: true,
              wechatAuthorizeUrl: 'https://example.com',
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<FButton>(
        find.byKey(const Key('wechat-complete-button')),
      );
      expect(button.onPress, isNull);
    });

    testWidgets('onStart is called when start button tapped', (tester) async {
      var startCalled = false;
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () => startCalled = true,
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('wechat-login-start-button')));
      await tester.pumpAndSettle();

      expect(startCalled, isTrue);
    });
  });

  group('OAuthButtonRow — QQ', () {
    testWidgets('renders start button', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('qq-login-start-button')), findsOneWidget);
    });

    testWidgets('start button disabled when isStarting', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: true,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<GestureDetector>(
        find.byKey(const Key('qq-login-start-button')),
      );
      expect(button.onTap, isNull);
    });

    testWidgets('shows callback input when authorizeUrl is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: 'https://graph.qq.com/oauth2.0/authorize',
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('qq-callback-input')), findsOneWidget);
    });

    testWidgets('hides callback input when authorizeUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('qq-callback-input')), findsNothing);
    });

    testWidgets('onStart called when start button tapped', (tester) async {
      var startCalled = false;
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () => startCalled = true,
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('qq-login-start-button')));
      await tester.pumpAndSettle();

      expect(startCalled, isTrue);
    });
  });

  group('OAuthButtonRow — Weibo', () {
    testWidgets('renders start button', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('weibo-login-start-button')), findsOneWidget);
    });

    testWidgets('start button disabled when isStarting', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: true,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<GestureDetector>(
        find.byKey(const Key('weibo-login-start-button')),
      );
      expect(button.onTap, isNull);
    });

    testWidgets('shows callback input when authorizeUrl is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: 'https://api.weibo.com/oauth2/authorize',
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('weibo-callback-input')), findsOneWidget);
    });

    testWidgets('onStart called when start button tapped', (tester) async {
      var startCalled = false;
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () => startCalled = true,
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('weibo-login-start-button')));
      await tester.pumpAndSettle();

      expect(startCalled, isTrue);
    });
  });

  group('OAuthButtonRow — Google', () {
    testWidgets('renders start button', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('google-login-start-button')),
        findsOneWidget,
      );
    });

    testWidgets('start button disabled when isStarting', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: true,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<GestureDetector>(
        find.byKey(const Key('google-login-start-button')),
      );
      expect(button.onTap, isNull);
    });

    testWidgets('shows callback input when authorizeUrl is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl:
                  'https://accounts.google.com/o/oauth2/v2/auth',
              onGoogleStart: () {},
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('google-callback-input')), findsOneWidget);
    });

    testWidgets('onStart called when start button tapped', (tester) async {
      var startCalled = false;
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: _buildRow(
              wechatCallbackController: TextEditingController(),
              isStartingWechat: false,
              isCompletingWechat: false,
              wechatAuthorizeUrl: null,
              onWechatStart: () {},
              onWechatComplete: () {},
              qqCallbackController: TextEditingController(),
              isStartingQq: false,
              isCompletingQq: false,
              qqAuthorizeUrl: null,
              onQqStart: () {},
              onQqComplete: () {},
              weiboCallbackController: TextEditingController(),
              isStartingWeibo: false,
              isCompletingWeibo: false,
              weiboAuthorizeUrl: null,
              onWeiboStart: () {},
              onWeiboComplete: () {},
              googleCallbackController: TextEditingController(),
              isStartingGoogle: false,
              isCompletingGoogle: false,
              googleAuthorizeUrl: null,
              onGoogleStart: () => startCalled = true,
              onGoogleComplete: () {},
              isStartingApple: false,
              onAppleSignIn: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('google-login-start-button')));
      await tester.pumpAndSettle();

      expect(startCalled, isTrue);
    });
  });
}
