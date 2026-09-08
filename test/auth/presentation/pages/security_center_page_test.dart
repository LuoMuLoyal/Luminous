import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/providers/sensitive_action_password.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/pages/security_center.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('Security center page renders when signed in', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account/security-center',
            routes: [
              GoRoute(
                path: '/account/security-center',
                builder: (context, state) => const SecurityCenterPage(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(l10n.authAccountManageSecurityCenter), findsOneWidget);
    expect(find.text(l10n.authLinkedIdentitiesSectionTitle), findsOneWidget);
    expect(
      find.text(l10n.securityCenterSensitiveOperationsTitle),
      findsOneWidget,
    );
    expect(find.text(l10n.securityCenterLoginHistoryTitle), findsOneWidget);
    expect(
      find.text(l10n.securityCenterAccountProtectionTitle),
      findsOneWidget,
    );
    expect(
      find.text(l10n.securityCenterAccountProtectionComingSoon),
      findsOneWidget,
    );
  });

  testWidgets('Security center page shows auth gate when signed out', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedOutAuthSessionNotifier(),
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account/security-center',
            routes: [
              GoRoute(
                path: '/account/security-center',
                builder: (context, state) => const SecurityCenterPage(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    // Should show login dialog when not authenticated
    expect(find.byType(FButton), findsWidgets);
  });

  testWidgets('Security center shows empty sensitive operations', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account/security-center',
            routes: [
              GoRoute(
                path: '/account/security-center',
                builder: (context, state) => const SecurityCenterPage(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.text(l10n.securityCenterSensitiveOperationsEmpty),
      findsOneWidget,
    );
  });

  testWidgets('Security center shows linked identities when present', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _SignedInWithIdentityAuthSessionNotifier(),
          ),
          sensitiveActionPasswordPromptProvider.overrideWithValue(
            (context, {title, message, label}) async => 'test-password',
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account/security-center',
            routes: [
              GoRoute(
                path: '/account/security-center',
                builder: (context, state) => const SecurityCenterPage(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    // Should show the linked identity provider label
    expect(find.text('微信网页'), findsOneWidget);
  });

  testWidgets('Security center login history button exists', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account/security-center',
            routes: [
              GoRoute(
                path: '/account/security-center',
                builder: (context, state) => const SecurityCenterPage(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(l10n.securityCenterLoginHistoryViewAll), findsOneWidget);
  });
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

class _SignedInWithIdentityAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        hasPassword: true,
        linkedIdentities: [
          AuthLinkedIdentity(
            id: 'identity-1',
            provider: 'wechat_web',
            email: null,
            emailVerifiedAt: null,
            linkedAt: DateTime.parse('2026-01-03T00:00:00Z'),
          ),
        ],
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}
