import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/providers/security_elevation.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/presentation/pages/change_email.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Change email page sends verification code for change-email', (
    tester,
  ) async {
    final remote = FakeLucentAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          securityElevationControllerProvider.overrideWith(
            _VerifiedSecurityElevationController.new,
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account/change-email',
            routes: [
              GoRoute(
                path: '/account/change-email',
                builder: (context, state) => const ChangeEmailPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText).at(0), 'next@example.com');
    await tester.tap(find.text('发送验证码'));
    await tester.pumpAndSettle();

    expect(remote.sentCodeEmail, 'next@example.com');
    expect(remote.sentCodeScene, AuthVerificationScene.changeEmail);
  });

  testWidgets('Change email page submits and updates session email', (
    tester,
  ) async {
    final remote = FakeLucentAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(remote),
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        securityElevationControllerProvider.overrideWith(
          _VerifiedSecurityElevationController.new,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account/change-email',
            routes: [
              GoRoute(
                path: '/account/change-email',
                builder: (context, state) => const ChangeEmailPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText).at(0), 'next@example.com');
    await tester.enterText(find.byType(EditableText).at(1), '123456');
    await tester.tap(find.widgetWithText(FButton, '更新邮箱'));
    await tester.pumpAndSettle();

    expect(remote.changeEmailNewEmail, 'next@example.com');
    expect(remote.changeEmailCode, '123456');
    expect(container.read(authSessionProvider).user?.email, 'next@example.com');
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Change email does not submit when Security PIN is disabled', (
    tester,
  ) async {
    final remote = FakeLucentAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          userSettingsControllerProvider.overrideWith(
            _DisabledSecurityPinSettingsController.new,
          ),
        ],
        child: TestAuthApp(
          router: GoRouter(
            initialLocation: '/account/change-email',
            routes: [
              GoRoute(
                path: '/account/change-email',
                builder: (context, state) => const ChangeEmailPage(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.enterText(find.byType(EditableText).at(0), 'next@example.com');
    await tester.enterText(find.byType(EditableText).at(1), '123456');
    await tester.tap(find.widgetWithText(FButton, '更新邮箱'));
    await tester.pumpAndSettle();

    expect(remote.changeEmailNewEmail, isNull);
  });
}

class _VerifiedSecurityElevationController extends SecurityElevationController {
  @override
  SecurityElevationState build() {
    final expiresAt = DateTime.now().add(const Duration(minutes: 5));
    ref
        .read(securityElevationTokenHolderProvider)
        .set('test-elevation-token', expiresAt);
    return SecurityElevationVerified(expiresAt: expiresAt);
  }
}

class _DisabledSecurityPinSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async {
    return const UserSettings(
      aiSummariesEnabled: false,
      dataSharingConsent: false,
      assistantEnabled: false,
      assistantMemoryEnabled: false,
      waterTargetCount: 8,
      assistantContext: AssistantContextSettings(
        healthProfile: false,
        dailyRecords: false,
        sleepRecords: false,
        currentMedicines: false,
      ),
      securityPin: SecurityPinSettings(enabled: false),
    );
  }
}
