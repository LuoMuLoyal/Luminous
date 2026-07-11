import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/oauth_panels.dart';

import '../helpers/test_forui_app.dart';

void main() {
  group('WechatOAuthPanel', () {
    testWidgets('renders start button when not loading', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: WechatOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: false,
              authorizeUrl: null,
              onStart: () {},
              onComplete: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('wechat-login-start-button')), findsOneWidget);
    });

    testWidgets('start button disabled when isStarting', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: WechatOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: true,
              isCompleting: false,
              authorizeUrl: null,
              onStart: () {},
              onComplete: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<FButton>(
        find.byKey(const Key('wechat-login-start-button')),
      );
      expect(button.onPress, isNull);
    });

    testWidgets('start button disabled when isCompleting', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: WechatOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: true,
              authorizeUrl: null,
              onStart: () {},
              onComplete: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<FButton>(
        find.byKey(const Key('wechat-login-start-button')),
      );
      expect(button.onPress, isNull);
    });

    testWidgets('shows callback input when authorizeUrl is set', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: WechatOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: false,
              authorizeUrl: 'https://open.weixin.qq.com/connect/oauth2/authorize',
              onStart: () {},
              onComplete: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('wechat-callback-input')), findsOneWidget);
    });

    testWidgets('hides callback input when authorizeUrl is null', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: WechatOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: false,
              authorizeUrl: null,
              onStart: () {},
              onComplete: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('wechat-callback-input')), findsNothing);
    });

    testWidgets('hides callback input when authorizeUrl is empty', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: WechatOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: false,
              authorizeUrl: '',
              onStart: () {},
              onComplete: () {},
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
            body: WechatOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: true,
              authorizeUrl: 'https://example.com',
              onStart: () {},
              onComplete: () {},
            ),
          ),
        ),
      );

      // Find the complete button (second FButton)
      final buttons = find.byType(FButton);
      final completeButton = tester.widget<FButton>(buttons.at(1));
      expect(completeButton.onPress, isNull);
    });

    testWidgets('onStart is called when start button tapped', (tester) async {
      var startCalled = false;
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: WechatOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: false,
              authorizeUrl: null,
              onStart: () => startCalled = true,
              onComplete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('wechat-login-start-button')));
      await tester.pumpAndSettle();

      expect(startCalled, isTrue);
    });
  });

  group('QqOAuthPanel', () {
    testWidgets('renders start button', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: QqOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: false,
              authorizeUrl: null,
              onStart: () {},
              onComplete: () {},
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
            body: QqOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: true,
              isCompleting: false,
              authorizeUrl: null,
              onStart: () {},
              onComplete: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<FButton>(
        find.byKey(const Key('qq-login-start-button')),
      );
      expect(button.onPress, isNull);
    });

    testWidgets('shows callback input when authorizeUrl is set', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: QqOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: false,
              authorizeUrl: 'https://graph.qq.com/oauth2.0/authorize',
              onStart: () {},
              onComplete: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('qq-callback-input')), findsOneWidget);
    });

    testWidgets('hides callback input when authorizeUrl is null', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: QqOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: false,
              authorizeUrl: null,
              onStart: () {},
              onComplete: () {},
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
            body: QqOAuthPanel(
              callbackController: TextEditingController(),
              isStarting: false,
              isCompleting: false,
              authorizeUrl: null,
              onStart: () => startCalled = true,
              onComplete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('qq-login-start-button')));
      await tester.pumpAndSettle();

      expect(startCalled, isTrue);
    });
  });
}
