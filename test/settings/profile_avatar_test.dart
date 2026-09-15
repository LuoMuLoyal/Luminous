import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
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
    expect(find.byKey(const Key('profile-activity-level-row')), findsOneWidget);
    expect(
      find.byKey(const Key('profile-dietary-preferences-row')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('profile-height-row')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quantity-sheet-picker')), findsOneWidget);
  });

  testWidgets('Failed health field save reports failure instead of success', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final repository = _FailingWriteRepository();
    final container = _container(repository: repository);

    await tester.pumpWidget(_app(container, showToaster: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-height-row')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quantity-sheet-picker')), findsOneWidget);
    // Confirm the sheet without moving the wheel: the write goes out and fails.
    final confirmButton = find.widgetWithText(FButton, l10n.mineEditSaveAction);
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    // Toast 展示 1.8s 后自动消失，不能 pumpAndSettle（会等到它退场再断言）。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(repository.updateProfileCalls, greaterThan(0));
    // The regression this guards against toasted "已保存" on a failed write.
    expect(find.text(l10n.mineEditSavedToast), findsNothing);
    expect(find.text(l10n.mineEditSaveFailedToast), findsOneWidget);

    // Drain the toast's 1.8s auto-dismiss timer before the test ends.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
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

      // FSelectMenuTile 行的 suffix 是 Forui 自带的 chevronsUpDown(布局仍由
      // Forui 落在行尾),只有自绘 actionNext 箭头的行才做贴右断言。
      final chevron = find.descendant(
        of: find.byWidget(row),
        matching: find.byIcon(SemanticIcons.actionNext),
      );
      if (tester.widgetList(chevron).isEmpty) continue;
      expect(
        group.right - tester.getRect(chevron).right,
        closeTo(tileRightInset, 0.5),
      );
    }
  });
}

const _storedAvatarUrl = 'https://cdn.example.com/avatar.png';

ProviderContainer _container({
  FakeLucentAuthRepository? remote,
  HealthContextRepository? repository,
}) {
  final container = ProviderContainer(
    overrides: [
      if (remote != null) authRepositoryProvider.overrideWithValue(remote),
      if (repository != null)
        healthContextRepositoryProvider.overrideWithValue(repository),
      authSessionProvider.overrideWith(() => _AvatarAuthSessionNotifier()),
      healthContextSnapshotProvider.overrideWith(
        (ref) => Future.value(_snapshot),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Repository whose profile writes always fail, so the page's failure feedback
/// can be asserted. Reads keep returning the fixture snapshot.
class _FailingWriteRepository implements HealthContextRepository {
  int updateProfileCalls = 0;

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> fetchHealthContext() =>
      TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) {
    updateProfileCalls++;
    return TaskEither.left(
      const LucentFailure(kind: LucentFailureKind.network, message: 'offline'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(ProviderContainer container, {bool showToaster = false}) {
  return UncontrolledProviderScope(
    container: container,
    child: TestForuiRouterApp(
      showToaster: showToaster,
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
    activityLevel: null,
    dietaryPreferences: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: '2026-01-01T00:00:00Z',
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);
