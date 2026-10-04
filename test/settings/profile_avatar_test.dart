import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/lucent_api.dart' as api;
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_action_view.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/data/services/avatar_uploader.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/settings/presentation/pages/profile.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../auth/test_helpers.dart';
import '../helpers/test_forui_app.dart';

class _MockFilesApi extends Mock implements api.FilesApi {}

class _MockDio extends Mock implements Dio {}

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

  testWidgets('Failed avatar removal reports failure instead of success', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final remote = FakeLucentAuthRepository()..failUpdateAccountProfile = true;
    final container = _container(remote: remote);

    await tester.pumpWidget(_app(container, showToaster: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-avatar-row')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.profileAvatarRemove));
    // Toast 展示 1.8s 后自动消失，不能 pumpAndSettle（会等到它退场再断言）。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 回归点：移除失败此前完全静默，用户以为已移除。
    expect(find.text(l10n.profileAvatarSaveFailed), findsOneWidget);
    expect(find.text(l10n.mineEditSavedToast), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  // 头像写入链路:presign → PUT 直传 → 把返回的 public URL PATCH 回 `/account`,
  // PATCH 的响应经 `applyUser` 落进 `authSessionProvider`——头像行渲染的就是它。
  // 这一组用真实的 [AvatarUploader] 套在被 mock 的 [FilesApi]/[Dio] 上跑完整条链路,
  // 同时断言请求形态与 UI 最终读到的值。
  //
  // 选图 → 裁剪那半边无法进 widget 测试:`XFile.readAsBytes` 是真的 dart:io I/O,
  // 在 FakeAsync zone 里永远不完成(与 `test/scan/box_scan_test.dart` 记录的排除口径
  // 一致),所以入口由下面直接调用 notifier 代替。
  group('avatar upload', () {
    late _MockFilesApi filesApi;
    late _MockDio dio;

    setUpAll(() {
      registerFallbackValue(
        api.CreateUploadRequest(contentType: 'image/jpeg', sizeBytes: 1),
      );
      registerFallbackValue(RequestOptions(path: ''));
    });

    setUp(() {
      filesApi = _MockFilesApi();
      dio = _MockDio();
    });

    testWidgets('a successful upload lands on the session user and the row', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      when(
        () => filesApi.createUpload(
          createUploadRequest: any(named: 'createUploadRequest'),
        ),
      ).thenAnswer(
        (_) async => Response<api.CreateFileUploadResponse>(
          requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
          data: api.CreateFileUploadResponse(
            provider: 's3',
            bucket: 'lucent',
            objectKey: 'files/user-1/object.jpg',
            uploadUrl: 'https://upload.example.com/signed',
            headers: const {'Content-Type': 'image/jpeg'},
            publicUrl: _uploadedAvatarUrl,
            expiresAt: '2026-01-01T00:00:00Z',
            maxSizeBytes: 10485760,
          ),
        ),
      );
      when(
        () => dio.put<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            Response<dynamic>(requestOptions: RequestOptions(path: '')),
      );

      final remote = FakeLucentAuthRepository();
      final container = _container(
        remote: remote,
        avatarUploader: AvatarUploader(filesApi: filesApi, dio: dio),
        hasStoredAvatar: false,
      );

      await tester.pumpWidget(_app(container));
      await tester.pumpAndSettle();
      expect(_rowAvatarUrl(tester), isNull);

      final uploaded = await _upload(container);
      await tester.pumpAndSettle();

      expect(uploaded, isTrue);
      // 上传返回的 public URL 必须写回账户资料……
      expect(remote.updateProfileAvatar, _uploadedAvatarUrl);
      // ……并且它就是头像渲染的取值来源(provider 与行的入参都要跟上)。
      expect(
        container.read(authSessionProvider).user?.avatar,
        _uploadedAvatarUrl,
      );
      expect(_rowAvatarUrl(tester), _uploadedAvatarUrl);

      // 服务端把 fileName 当「原始文件名」校验(不允许路径分隔符),直传前必须只剩
      // 文件名——头像上传此前发的是 `avatars/{userId}/avatar-xxx.jpg`,每个请求都被
      // 400 打回,头像因此永远不落地。
      final request =
          verify(
                () => filesApi.createUpload(
                  createUploadRequest: captureAny(named: 'createUploadRequest'),
                ),
              ).captured.single
              as api.CreateUploadRequest;
      expect(request.fileName, isNot(matches(RegExp(r'[\\/]'))));
    });

    testWidgets('a failed upload surfaces the failure and writes nothing', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      // presign 被服务端拒绝(请求校验失败的形态)。
      when(
        () => filesApi.createUpload(
          createUploadRequest: any(named: 'createUploadRequest'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
          type: DioExceptionType.badResponse,
          response: problemResponse(
            path: '/api/v1/user/files/upload',
            statusCode: 400,
            code: 'VALIDATION_FAILED',
            detail: 'fileName must not contain a path separator',
          ),
        ),
      );

      final remote = FakeLucentAuthRepository();
      final container = _container(
        remote: remote,
        avatarUploader: AvatarUploader(filesApi: filesApi, dio: dio),
        hasStoredAvatar: false,
      );

      await tester.pumpWidget(_app(container));
      await tester.pumpAndSettle();

      final uploaded = await _upload(container);
      await tester.pumpAndSettle();

      // 失败不能伪装成成功:notifier 返回 false(调用点据此提示失败),账户资料
      // 一次都没写,头像 provider/行保持原值(null),直传也没发生。
      expect(uploaded, isFalse);
      expect(container.read(authAccountProvider).errorMessage, isNotNull);
      expect(remote.updateProfileAvatar, isNull);
      expect(container.read(authSessionProvider).user?.avatar, isNull);
      expect(_rowAvatarUrl(tester), isNull);
      verifyNever(
        () => dio.put<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      );
    });
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
  AvatarUploader? avatarUploader,
  bool hasStoredAvatar = true,
}) {
  final container = ProviderContainer(
    overrides: [
      if (remote != null) authRepositoryProvider.overrideWithValue(remote),
      if (repository != null)
        healthContextRepositoryProvider.overrideWithValue(repository),
      if (avatarUploader != null)
        avatarUploaderProvider.overrideWithValue(avatarUploader),
      authSessionProvider.overrideWith(
        hasStoredAvatar
            ? _AvatarAuthSessionNotifier.new
            : _EmptyAvatarAuthSessionNotifier.new,
      ),
      healthContextSnapshotProvider.overrideWith(
        (ref) => Future.value(_snapshot),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Drives the same write the avatar row's gallery action drives
/// (`ProfilePage.editAvatar` → `AuthAccountNotifier.uploadAvatar`).
Future<bool> _upload(ProviderContainer container) {
  return container
      .read(authAccountProvider.notifier)
      .uploadAvatar(
        bytes: Uint8List.fromList(const <int>[1, 2, 3]),
        fileName: 'avatar.jpg',
        contentType: 'image/jpeg',
      );
}

/// The URL the profile avatar row is currently rendering (`bytes` wins over the
/// URL inside [AvatarView], so both are relevant).
String? _rowAvatarUrl(WidgetTester tester) =>
    tester.widget<AvatarActionView>(find.byType(AvatarActionView)).avatarUrl;

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

/// Signed-in user with no avatar, so an upload's effect on the rendered avatar
/// (null → URL) is unambiguous.
class _EmptyAvatarAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => _emptyAvatarSession;
}

final _emptyAvatarSession = AuthSessionState(
  isAuthenticated: true,
  isLoading: false,
  user: AuthUser(
    id: 'user-1',
    email: 'user@example.com',
    nickname: 'Lumi',
    avatar: null,
    emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
    hasPassword: true,
    createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
    updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
  ),
);

/// The public URL a stubbed presign hands back for an uploaded avatar.
const _uploadedAvatarUrl = 'https://cdn.example.com/uploaded-avatar.jpg';

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
