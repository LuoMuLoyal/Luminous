import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/pages/account_identity.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/branding.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('AuthBrandLogo renders', (tester) async {
    await tester.pumpWidget(const TestForuiApp(home: AuthBrandLogo()));
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });

  testWidgets('AuthBrandLogo with custom size', (tester) async {
    await tester.pumpWidget(const TestForuiApp(home: AuthBrandLogo(size: 80)));
    expect(find.byType(AuthBrandLogo), findsOneWidget);
  });

  group('LinkedIdentitiesSection WeChat entry', () {
    testWidgets('renders the link button when a callback is provided', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      var linked = false;

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: LinkedIdentitiesSection(
              user: _user,
              isSubmitting: false,
              onLinkWechat: () async => linked = true,
              onUnlink: (_) async {},
            ),
          ),
        ),
      );

      final button = find.byKey(const Key('wechat-identity-link-button'));
      expect(button, findsOneWidget);
      expect(find.text(l10n.authIdentityLinkWechatAction), findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(linked, isTrue);
    });

    testWidgets('omits the button when no callback is provided', (
      tester,
    ) async {
      // 隐藏入口的宿主页传 null——死分支应在组件内被消掉，而不是靠调用方
      // 传一个永远不可达的空回调。
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: LinkedIdentitiesSection(
              user: _user,
              isSubmitting: false,
              onLinkWechat: null,
              onUnlink: _noopUnlink,
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('wechat-identity-link-button')),
        findsNothing,
      );
    });
  });
  group('AuthTermsNotice terms line', () {
    testWidgets('renders prefix, links and connector with no dangling word', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: AuthTermsNotice(onTerms: () {}, onPrivacy: () {}),
          ),
        ),
      );

      // 前缀与连接词各自独立成键；此前靠裁剪模板尾部再按 localeName 硬编码连接词，
      // 模板一改就渲染出悬空的「与」。
      expect(find.text(l10n.authTermsAgreementPrefix), findsOneWidget);
      expect(find.text(l10n.authTermsConjunction), findsOneWidget);
      expect(find.text(l10n.authTermsOfService), findsOneWidget);
      expect(find.text(l10n.authPrivacyPolicy), findsOneWidget);
    });

    testWidgets('uses the English connector under the en locale', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.pumpWidget(
        TestForuiApp(
          locale: const Locale('en'),
          home: Scaffold(
            body: AuthTermsNotice(onTerms: () {}, onPrivacy: () {}),
          ),
        ),
      );

      expect(find.text(l10n.authTermsConjunction), findsOneWidget);
    });
  });
}

Future<void> _noopUnlink(AuthLinkedIdentity identity) async {}

final _user = AuthUser(
  id: 'user-1',
  email: 'user@example.com',
  nickname: 'Lumi',
  avatar: null,
  emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
  hasPassword: true,
  createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
  updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
);
