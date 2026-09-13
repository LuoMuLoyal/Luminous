import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/settings/presentation/pages/profile.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../auth/test_helpers.dart';
import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('Profile avatar row opens the actions dialog', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final container = _container();

    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    // The page is a read-only list now: no inline URL entry, and editing starts
    // from the row rather than a corner badge.
    expect(find.byKey(const Key('profile-avatar-field')), findsNothing);
    expect(find.byKey(const Key('profile-avatar-row')), findsOneWidget);
    expect(find.byKey(const Key('profile-nickname-row')), findsOneWidget);
    expect(find.byKey(const Key('profile-email-row')), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-avatar-row')));
    await tester.pumpAndSettle();

    expect(find.text(l10n.profileAvatarActionsTitle), findsOneWidget);
    expect(find.text(l10n.profileAvatarTakePhoto), findsOneWidget);
    expect(find.text(l10n.profileAvatarChooseFromGallery), findsOneWidget);
    expect(find.text(l10n.profileAvatarRemove), findsOneWidget);
    expect(find.text(l10n.profileAvatarView), findsOneWidget);
  });

  testWidgets('Profile nickname row edits through a sheet', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final remote = FakeLucentAuthRepository();
    final container = _container(remote: remote);

    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-nickname-row')));
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('edit-sheet-text-field'));
    expect(field, findsOneWidget);

    await tester.enterText(field, '  Lumi 2  ');
    await tester.tap(find.text('保存'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(remote.updateProfileNickname, 'Lumi 2');
    // A nickname edit must not clear or rewrite the stored avatar.
    expect(remote.updateProfileAvatar, _storedAvatarUrl);
  });

  testWidgets('Profile health rows open a single-field sheet', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final container = _container();

    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-birthdate-row')), findsOneWidget);
    expect(find.byKey(const Key('profile-height-row')), findsOneWidget);
    expect(find.byKey(const Key('profile-blood-type-row')), findsOneWidget);
    expect(find.byKey(const Key('profile-emergency-name-row')), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-height-row')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('edit-sheet-text-field')), findsOneWidget);
  });

  testWidgets('Profile rows pin the value and chevron to the group edge', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final container = _container();

    await tester.pumpWidget(_app(container));
    await tester.pumpAndSettle();

    expect(find.byType(FTile), findsWidgets);
    final rows = tester
        .widgetList<FTile>(find.byType(FTile))
        .map((row) => (row, tester.getRect(find.byWidget(row))))
        .toList();

    // Each row is a Forui tile, so it fills the FTileGroup it belongs to and its
    // chevron lands on that group's trailing edge — Forui's tile padding is the
    // only inset. The regression this guards against left the value and chevron
    // drifting inwards, each row by a different amount.
    final group = tester.getRect(find.byType(FTileGroup).first);
    const tileRightInset = 13.0;
    for (final (row, rect) in rows) {
      if (rect.left < group.left - 0.5) continue; // a different group
      expect(rect.left, closeTo(group.left, 0.5));
      expect(rect.right, closeTo(group.right, 0.5));

      final chevron = tester.getRect(
        find.descendant(
          of: find.byWidget(row),
          matching: find.byIcon(SemanticIcons.actionNext),
        ),
      );
      expect(group.right - chevron.right, closeTo(tileRightInset, 0.5));
    }
  });
}

const _storedAvatarUrl = 'https://cdn.example.com/avatar.png';

ProviderContainer _container({FakeLucentAuthRepository? remote}) {
  final container = ProviderContainer(
    overrides: [
      if (remote != null) authRepositoryProvider.overrideWithValue(remote),
      authSessionProvider.overrideWith(() => _AvatarAuthSessionNotifier()),
      healthContextSnapshotProvider.overrideWith(
        (ref) => Future.value(_snapshot),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _app(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: TestForuiRouterApp(
      routerConfig: GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ),
  );
}

/// Signed-in user that already has a stored avatar, so an avatar write can be
/// distinguished from a cleared value.
class _AvatarAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: _storedAvatarUrl,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        hasPassword: true,
        lastLoginAt: DateTime.parse('2026-01-02T08:30:00Z'),
        linkedIdentities: const [],
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

const _snapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: '1999-01-15',
    sexAtBirth: 'female',
    heightCm: 170.0,
    weightKg: 60.0,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: '2026-01-01T00:00:00Z',
    emergencyContactName: null,
    emergencyContactPhone: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);
