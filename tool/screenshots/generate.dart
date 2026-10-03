// Page-catalog screenshot generator (host-side, no device).
//
// Produces the full prefilled page-catalog PNG set by rendering the real app
// under a self-authored simulated dataset inside a plain `flutter test` run:
// no emulator, no Gradle build, no adb pull, no teardown-uninstall deleting the
// output, and no 45s hold window.
//
// Run (PowerShell, from `Luminous/`):
//
//     flutter test tool/screenshots/generate.dart --update-goldens
//
// Narrow to one page while iterating:
//
//     flutter test tool/screenshots/generate.dart --update-goldens `
//       --plain-name "generate shell/today"
//
// Output: `outputs/screenshots/<order>_<group>_<page-id>.png` at 1344x2992
// (Pixel 8 Pro frame: 448x997.33 logical @ dpr 3), plus `MANIFEST.md`.
// `outputs/` is gitignored, so generated images never enter the repo.
//
// Why this file is not under `test/`: a bare `flutter test` scans `test/` only,
// so the generator never runs in CI (the repo deliberately removed golden
// baselines after CI pixel drift). It is a generator, not a regression
// baseline.
//
// Why `matchesGoldenFile` and not manual `RepaintBoundary.toImage`: manual
// raster capture deadlocks in this binding when a pump follows the encode
// (flutter/flutter#49317). `matchesGoldenFile` uses the supported raster path.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/bootstrap.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart'
    show assistantRepositoryProvider;
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_data/data/providers/health_sync.dart'
    show healthSyncRepositoryProvider;
import 'package:luminous/features/legal/data/repositories/lucent.dart'
    show legalRepositoryProvider;
import 'package:luminous/features/medicine/data/providers/workspace.dart'
    show medicineWorkspaceRepositoryProvider, reminderRepositoryProvider;
import 'package:luminous/features/medicine/data/repositories/risk_check.dart'
    show medicineRiskCheckRepositoryProvider;
import 'package:luminous/features/medicine/presentation/providers/medicine_detail.dart'
    show medicineDetailProvider;
import 'package:luminous/features/medicine/presentation/providers/reminders.dart'
    show
        medicineReminderDeliveryLogProvider,
        medicineReminderListProvider,
        medicineTodayDoseLogsProvider;
import 'package:luminous/features/mine/data/providers/mine.dart'
    show mineRepositoryProvider;
import 'package:luminous/features/mine/presentation/providers/sync_failures.dart'
    show mineSyncFailedEntriesProvider;
import 'package:luminous/features/notification/data/providers/unread_count.dart'
    show notificationUnreadCountProvider;
import 'package:luminous/features/notification/data/repositories/lucent.dart'
    show notificationRepositoryProvider;
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/review/data/providers/review.dart'
    show reviewDashboardRepositoryProvider;
import 'package:luminous/features/review/presentation/providers/review.dart'
    show reviewCurrentProvider, reviewHistoryProvider;
import 'package:luminous/features/scan/data/repositories/scan.dart'
    show scanRepositoryProvider;
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/presentation/pages/box_scan.dart'
    show showMedicineBoxScanSheet;
import 'package:luminous/features/scan/presentation/widgets/dialogs/recognize_dialog.dart'
    show MedicineRecognizeDialog;
import 'package:luminous/features/search/data/repositories/lucent.dart'
    show medicineSearchRepositoryProvider;
import 'package:luminous/features/search/presentation/providers/medicine_search.dart'
    show medicineSearchNotifierProvider;
import 'package:luminous/features/settings/data/repositories/lucent.dart'
    show userSettingsRepositoryProvider;
import 'package:luminous/features/support/data/repositories/lucent.dart'
    show supportRepositoryProvider;
import 'package:luminous/features/today/data/providers/today_suggestion.dart'
    show todayRepositoryProvider;
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../integration_test/screenshots/page_catalog_screenshot_test.dart'
    as catalog;
import 'simulated_fakes_assistant.dart';
import 'simulated_fakes_misc.dart';
import 'simulated_fakes_review.dart';
import 'simulated_fakes_shell_a.dart';
import 'simulated_fakes_shell_b.dart';

// ── Frame ───────────────────────────────────────────────────────────────────

/// Pixel 8 Pro: 1344x2992 physical at density 480 (dpr 3).
const double _frameWidth = 448;
const double _frameHeight = 2992 / 3;
const double _frameDpr = 3;

/// Capture directory; the golden comparator resolves this against this file.
const String _outputDir = '../../outputs/screenshots';

/// Project-relative form of [_outputDir], for the manifest write.
const String _outputDirRelative = 'outputs/screenshots';

// ── Platform channel stubs ──────────────────────────────────────────────────
//
// On the host `Platform.isWindows` is true under `flutter_tester`, so the app
// takes its desktop-window branch and the bootstrap touches a few plugins.
// Without an implementation those calls throw MissingPluginException, which
// fails every capture and can hang the run. Stub exactly the channels reached.
void _installPlatformStubs() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(
    const MethodChannel('window_manager'),
    (call) async => switch (call.method) {
      'isMaximized' || 'isFullScreen' || 'isPreventClose' => false,
      'isFocused' => true,
      'getPosition' => const <double>[0, 0],
      'getSize' => const <double>[_frameWidth, _frameHeight],
      _ => null,
    },
  );

  final cacheDir = Directory.systemTemp.path;
  messenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => switch (call.method) {
      'getApplicationDocumentsDirectory' ||
      'getTemporaryDirectory' ||
      'getApplicationSupportDirectory' ||
      'getLibraryDirectory' => cacheDir,
      _ => null,
    },
  );

  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/package_info'),
    (call) async => call.method == 'getAll'
        ? <String, Object?>{
            'appName': 'Luminous',
            'packageName': 'com.dev.luminous',
            'version': '0.0.0',
            'buildNumber': '0',
            'buildSignature': '',
          }
        : null,
  );

  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (call) async => call.method == 'check' ? <String>['wifi'] : null,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
    (call) async => null,
  );

  // Camera permission gate reached by the scan page. PermissionStatus codes
  // are positional in permission_handler_platform_interface: 0 = denied,
  // 1 = granted. Anything but granted renders the "camera permission denied"
  // card instead of the scanner.
  messenger.setMockMethodCallHandler(
    const MethodChannel('flutter.baseflow.com/permissions/methods'),
    (call) async => switch (call.method) {
      'checkPermissionStatus' => 1,
      'requestPermissions' || 'requestSinglePermission' => <int, int>{0: 1},
      'shouldShowRequestPermissionRationale' => false,
      'openAppSettings' => true,
      _ => null,
    },
  );

  // `mobile_scanner` is not faked here (its platform interface lives in the
  // test helpers, which this tool does not import); the controller only needs
  // the native lifecycle calls to resolve instead of throwing
  // MissingPluginException mid-capture. `state` is the *authorization* state
  // (1 = authorized), while `start` returns the view configuration.
  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.steenbakker.mobile_scanner/scanner/method'),
    (call) async => switch (call.method) {
      'state' => 1,
      'request' => true,
      'getSupportedLenses' => <String>['any'],
      'start' => <String, Object?>{
        'textureId': 1,
        'cameraDirection': 0,
        'numberOfCameras': 1,
        'currentTorchState': 0,
        'size': <String, Object?>{'width': 640.0, 'height': 480.0},
        'handlesCropAndRotation': true,
        'naturalDeviceOrientation': 'PORTRAIT_UP',
        'sensorOrientation': 90,
      },
      'stop' ||
      'dispose' ||
      'toggleTorch' ||
      'setScale' ||
      'pause' ||
      'updateScanWindow' => null,
      _ => null,
    },
  );
  for (final channel in const [
    'dev.steenbakker.mobile_scanner/scanner/deviceOrientation',
    'dev.steenbakker.mobile_scanner/scanner/event',
  ]) {
    messenger.setMockStreamHandler(
      EventChannel(channel),
      _EmptyStreamHandler(),
    );
  }
}

/// Emits a single "never" event so `EventChannel.receiveBroadcastStream()`
/// completes its handshake without a live platform implementation.
class _EmptyStreamHandler extends MockStreamHandler {
  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    // Intentionally silent: the scan page renders its idle frame either way.
  }

  @override
  void onCancel(Object? arguments) {}
}

// ── Fonts ───────────────────────────────────────────────────────────────────
//
// `flutter test` rasterizes with the built-in "FlutterTest" font, which draws
// every glyph as an empty box. Three families must be registered for the
// captures to be readable:
//
//  * `packages/forui/Inter` — the family Forui's typography actually asks for.
//    Registering a CJK face here is what covers Chinese; registering it under a
//    made-up name (e.g. 'Microsoft YaHei') silently does nothing.
//  * the icon families (`MaterialIcons`, Forui lucide/phosphor).
//  * `monospace` — markdown/legal bodies.
//
// Package fonts are already in the test asset bundle, so `rootBundle.load`
// reaches them; only the CJK face comes from the host.

const List<String> _cjkFontCandidates = <String>[
  r'C:\Windows\Fonts\Noto Sans SC (TrueType).otf',
  r'C:\Windows\Fonts\NotoSansSC-VF.ttf',
  r'C:\Windows\Fonts\Deng.ttf',
  r'C:\Windows\Fonts\simhei.ttf',
  '/System/Library/Fonts/PingFang.ttc',
  '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',
];

const List<String> _monoFontCandidates = <String>[
  r'C:\Windows\Fonts\consola.ttf',
  '/System/Library/Fonts/Menlo.ttc',
  '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf',
];

Future<ByteData?> _hostFont(List<String> candidates) async {
  for (final path in candidates) {
    final file = File(path);
    if (file.existsSync()) {
      return ByteData.sublistView(Uint8List.fromList(file.readAsBytesSync()));
    }
  }
  return null;
}

Future<void> _loadFont(String family, ByteData bytes) async {
  await (FontLoader(family)..addFont(Future<ByteData>.value(bytes))).load();
}

Future<void> _loadFonts() async {
  final cjk = await _hostFont(_cjkFontCandidates);
  if (cjk != null) {
    // One face per family: the engine picks the first face, so a second
    // registration under the same family would not add a Latin fallback.
    await _loadFont('packages/forui/Inter', cjk);
    await _loadFont('Roboto', cjk);
  }

  final mono = await _hostFont(_monoFontCandidates);
  if (mono != null) {
    await _loadFont('monospace', mono);
  }

  await _loadFont(
    'MaterialIcons',
    await rootBundle.load('fonts/MaterialIcons-Regular.otf'),
  );
  await _loadFont(
    'packages/forui_lucide/ForuiLucideIcons',
    await rootBundle.load('packages/forui_lucide/assets/lucide.ttf'),
  );
  for (final variant in const <String>[
    'regular',
    'thin',
    'light',
    'bold',
    'fill',
    'duotone',
  ]) {
    final suffix = '${variant[0].toUpperCase()}${variant.substring(1)}';
    await _loadFont(
      'packages/forui_phosphor/ForuiPhosphor${suffix}Icons',
      await rootBundle.load('packages/forui_phosphor/assets/$variant.ttf'),
    );
  }

  // ignore: avoid_print
  print('FONTS cjk=${cjk != null} mono=${mono != null}');
}

// ── Route resolution ────────────────────────────────────────────────────────

/// Rewrites the catalog's e2e placeholder ids onto the simulated dataset.
///
/// The committed catalog points at fixture ids from the e2e stack
/// (`e2e-allergy-1`, `e2e-medicine-1`, `__mock_cn_ibuprofen__`, …). This
/// generator deliberately runs against its own simulated data, so those ids
/// would resolve to "记录不存在" / "提醒暂时没有加载出来". Mapping them here keeps
/// the committed catalog untouched.
String _resolveRoute(String route) {
  const replacements = <String, String>{
    '/medicine/reminders/e2e-medicine-1/edit':
        '/medicine/reminders/$_simMedicineId0/edit',
    '/medicine/reminders/e2e-medicine-1':
        '/medicine/reminders/$_simMedicineId0',
    '/mine/allergy/e2e-allergy-1/edit': '/mine/allergy/$_simAllergyId/edit',
    '/mine/condition/e2e-condition-1/edit':
        '/mine/condition/$_simConditionId/edit',
    '/mine/medicine/e2e-medicine-1/edit':
        '/mine/medicine/$_simMedicineId0/edit',
    '/medicine/detail/cn/__mock_cn_ibuprofen__':
        '/medicine/detail/cn/$_simMedicineSourceRefId0',
  };
  return replacements[route] ?? route;
}

/// Current-medicine ids in the simulated health-context snapshot
/// (`simulated_fakes_misc.dart`).
const String _simMedicineId0 = 'cm_amlodipine_2026';
const String _simAllergyId = 'alg-penicillin-2026';
const String _simConditionId = 'cnd-hypertension-2026';

/// Source reference id of the first simulated current medicine.
const String _simMedicineSourceRefId0 = 'cn-amlodipine-5mg';

// ── Simulated session ───────────────────────────────────────────────────────

/// The simulated signed-in user every capture renders as.
///
/// Authored for this generator: a plausible mid-use account, not a test
/// placeholder.
const String _simUserId = 'sim-user-chenjing';
const String _simUserEmail = 'chen.jing@example.com';
const String _simUserNickname = '陈静';

class _SimulatedAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => AuthSessionState(
    isAuthenticated: true,
    isLoading: false,
    user: AuthUser(
      id: _simUserId,
      email: _simUserEmail,
      nickname: _simUserNickname,
      avatar: null,
      emailVerifiedAt: DateTime.utc(2026, 3, 4),
      hasPassword: true,
      createdAt: DateTime.utc(2026, 2, 18),
      updatedAt: DateTime.utc(2026, 10, 2),
    ),
  );

  @override
  Future<void> restore() async {}
}

// ── Fixtures ────────────────────────────────────────────────────────────────

/// Boots the real app against the simulated dataset.
///
/// `retry: (_, _) => null` disables Riverpod's automatic retry timer: any
/// simulated provider that surfaces an error would otherwise leave a pending
/// timer, and the test binding fails the case with "A Timer is still pending"
/// after the capture has already been written.
Future<ProviderContainer> _pumpPage(
  WidgetTester tester, {
  AssistantConversation? assistantConversation,
  bool signedIn = true,
}) async {
  // ignore: invalid_use_of_visible_for_testing_member -- this file is a test-run generator.
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await prefs.setString('app.locale', 'zh-CN');

  const healthContext = SimulatedHealthContextRepository();

  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      if (signedIn)
        authSessionProvider.overrideWith(_SimulatedAuthSessionNotifier.new),

      // Five-tab shell surfaces.
      todayRepositoryProvider.overrideWithValue(
        const SimulatedTodayRepository(),
      ),
      recordRepositoryProvider.overrideWithValue(
        const SimulatedRecordRepository(),
      ),
      dailyRecordRepositoryProvider.overrideWithValue(
        const SimulatedDailyRecordRepository(),
      ),
      mineRepositoryProvider.overrideWithValue(const SimulatedMineRepository()),
      medicineWorkspaceRepositoryProvider.overrideWithValue(
        const SimulatedMedicineWorkspaceRepository(),
      ),
      reviewDashboardRepositoryProvider.overrideWithValue(
        const SimulatedReviewDashboardRepository(),
      ),

      // Secondary surfaces.
      notificationRepositoryProvider.overrideWithValue(
        SimulatedNotificationRepository(),
      ),
      reminderRepositoryProvider.overrideWithValue(
        SimulatedReminderRepository(),
      ),

      // The reminder pages read the remote data source directly rather than the
      // repository, so override the presentation providers too — otherwise they
      // hit the real network and render the "提醒暂时没有加载出来" error card.
      medicineReminderListProvider.overrideWith(
        (ref) async => simulatedReminders(),
      ),
      medicineTodayDoseLogsProvider.overrideWith(
        (ref) async => simulatedTodayDoseLogs(),
      ),
      medicineReminderDeliveryLogProvider.overrideWith(
        (ref) async => simulatedReminderDeliveries(),
      ),
      assistantRepositoryProvider.overrideWithValue(
        SimulatedAssistantRepository(conversation: assistantConversation),
      ),
      healthSyncRepositoryProvider.overrideWithValue(
        SimulatedHealthSyncRepository(),
      ),
      medicineSearchRepositoryProvider.overrideWithValue(
        SimulatedMedicineSearchRepository(),
      ),
      medicineRiskCheckRepositoryProvider.overrideWithValue(
        SimulatedRiskCheckRepository(),
      ),
      legalRepositoryProvider.overrideWithValue(SimulatedLegalRepository()),
      supportRepositoryProvider.overrideWithValue(SimulatedSupportRepository()),
      userSettingsRepositoryProvider.overrideWithValue(
        SimulatedUserSettingsRepository(),
      ),
      scanRepositoryProvider.overrideWithValue(SimulatedScanRepository()),

      // Health-context snapshot hub, derived from the simulated archive so the
      // Mine / medicine / profile surfaces agree with each other.
      healthContextRepositoryProvider.overrideWithValue(healthContext),
      healthContextSnapshotProvider.overrideWith((ref) async {
        final result = await healthContext.fetchHealthContext().run();
        return result.fold((failure) => throw failure, (snapshot) => snapshot);
      }),

      todaySuggestionProvider.overrideWith(
        SimulatedTodaySuggestionNotifier.new,
      ),
      notificationUnreadCountProvider.overrideWith((ref) => Future.value(3)),

      // Review tab event-review providers. These are backed by the real
      // `ReviewRepository`; leaving them unmounted makes the page perform a
      // real network call whose `.timeout(10s)` leaves a pending timer and
      // fails the capture after the PNG was already written.
      reviewCurrentProvider.overrideWith(
        (ref) async => buildSimulatedEventReview(),
      ),
      reviewHistoryProvider.overrideWith(
        (ref) async => buildSimulatedReviewHistory(),
      ),

      // Local-only surfaces that read the drift DAO rather than a repository.
      mineSyncFailedEntriesProvider.overrideWith(
        (ref) => simulatedPendingSyncFailures,
      ),

      // The medicine knowledge detail provider builds its remote data source
      // directly, so override the family itself. A family override receives the
      // whole argument record, not its positional parts.
      medicineDetailProvider.overrideWith(
        (ref, args) => SimulatedMedicineDetailRepository().fetchDetail(
          id: args.$2,
          source: args.$1,
        ),
      ),
    ],
  );

  container.read(appRouterProvider).go('/');

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LuminousApp()),
  );

  await _settle(tester);

  // Disposal happens in the test body so pending provider timers are drained
  // before the binding's end-of-test invariant check.
  return container;
}

/// Pumps a bounded number of frames until the tree stops scheduling them.
///
/// `pumpAndSettle` hangs on pages with an indefinite animation (shimmer
/// skeleton, spinner), so settle manually with a bound.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) {
      await tester.pump(const Duration(milliseconds: 100));
      return;
    }
  }
}

// ── Runner ──────────────────────────────────────────────────────────────────

/// Puts a freshly-navigated page into the state the screenshot should show.
///
/// Some catalog routes land on a blank form (search, reminder-new) because the
/// interesting content only exists after user input. Driving that input through
/// the notifier is far cheaper than synthesising text-field gestures.
Future<void> _primeRoute(
  ProviderContainer container,
  WidgetTester tester,
  String route,
) async {
  switch (route) {
    case '/medicine/search':
      await container
          .read(medicineSearchNotifierProvider.notifier)
          .updateQuery('氨氯地平');
      // The notifier debounces by 400 ms before searching.
      await tester.pump(const Duration(milliseconds: 500));
      await _settle(tester);
    case '/medicine/risk-check':
      // Kick the check so the page shows findings instead of an idle prompt.
      await _settle(tester);
  }
}

// ── Extra surfaces ──────────────────────────────────────────────────────────
//
// The catalog is one shot per route; several real capabilities only exist in a
// state a single at-rest route cannot show (a confirmation card awaiting a tap,
// an expanded source strip, a photo-recognition dialog). These extras reuse the
// same pump/capture machinery and are numbered after the catalog so the two sets
// sort together in `outputs/screenshots/`.

/// One extra capture: a filename-independent description plus the setup that
/// drives the app into the state to shoot.
class _ExtraCapture {
  const _ExtraCapture({
    required this.fileName,
    required this.group,
    required this.page,
    required this.route,
    required this.note,
    this.assistantConversation,
    this.prepare,
    this.signedOut = false,
  });

  final String fileName;
  final String group;
  final String page;
  final String route;
  final String note;

  /// Overrides the assistant fixture so the page loads a richer conversation.
  final AssistantConversation? assistantConversation;

  /// Runs after navigation; the place to open drawers/dialogs and pump.
  final Future<void> Function(WidgetTester tester)? prepare;

  /// Renders the app signed out.
  ///
  /// Every catalog capture renders the simulated signed-in user, and the router
  /// sends an authenticated session away from `/login`. Auth surfaces therefore
  /// cannot use the shared session override: with it they redirect before the
  /// golden is taken, which shows up as a capture of the shell rather than the
  /// form.
  final bool signedOut;
}

final List<_ExtraCapture> _extraCaptures = <_ExtraCapture>[
  _ExtraCapture(
    fileName: '46_assistant_write_proposal.png',
    group: 'assistant',
    page: 'write-proposal',
    route: '/assistant',
    note: '工具写入待确认：create_daily_record 草稿卡片（确认前未写入）',
    assistantConversation: buildAssistantPendingWriteConversation(),
  ),
  _ExtraCapture(
    fileName: '47_assistant_write_confirmed.png',
    group: 'assistant',
    page: 'write-confirmed',
    route: '/assistant',
    note: '工具写入已确认：approve 后后端执行、卡片转为已确认',
    assistantConversation: buildAssistantConfirmedWriteConversation(),
  ),
  _ExtraCapture(
    fileName: '48_assistant_source_detail.png',
    group: 'assistant',
    page: 'source-detail',
    route: '/assistant',
    note: '来源条展开：工具覆盖度/置信度/歧义/来源表/溯源引用',
    assistantConversation: buildAssistantToolSourceConversation(),
    prepare: (tester) async {
      await tester.tap(find.byKey(const Key('assistant-source-strip')).first);
      await _settle(tester);
    },
  ),
  _ExtraCapture(
    fileName: '49_assistant_capabilities.png',
    group: 'assistant',
    page: 'capabilities',
    route: '/assistant',
    note: '能力面板：可用工具清单与状态（含未授权工具）',
    prepare: (tester) async {
      await tester.tap(find.byKey(const Key('assistant-capabilities-action')));
      await _settle(tester);
    },
  ),
  _ExtraCapture(
    fileName: '50_assistant_conversations.png',
    group: 'assistant',
    page: 'conversations',
    route: '/assistant',
    note: '会话抽屉：近期会话列表、当前会话与搜索入口',
    prepare: (tester) async {
      await tester.tap(
        find.byKey(const Key('assistant-recent-conversations-action')),
      );
      await _settle(tester);
    },
  ),
  _ExtraCapture(
    fileName: '51_assistant_replaced_answer.png',
    group: 'assistant',
    page: 'replaced-answer',
    route: '/assistant',
    note: '重新生成后的旧回答灰态与「已替换」标签',
    assistantConversation: buildAssistantReplacedConversation(),
  ),
  _ExtraCapture(
    fileName: '52_scan_photo_method_picker.png',
    group: 'scan',
    page: 'photo-method-picker',
    route: '/medicine/search',
    note: '药物图检索入口：OCR 文字识别 / AI 智能识别方式选择',
    prepare: (tester) async {
      // Not awaited: the sheet only completes when the user picks a method, and
      // the screenshot is taken while it is still open.
      unawaited(showMedicineBoxScanSheet(_hostContext(tester)));
      await _settle(tester);
    },
  ),
  _ExtraCapture(
    fileName: '53_scan_photo_recognize_ocr.png',
    group: 'scan',
    page: 'photo-recognize-ocr',
    route: '/medicine/search',
    note: '药物图检索结果：OCR 路径候选匹配与置信度排序',
    prepare: (tester) async {
      await _showRecognizeDialog(tester, MedicineScanMethod.ocr, 'OCR 文字识别');
    },
  ),
  _ExtraCapture(
    fileName: '54_scan_photo_recognize_ai.png',
    group: 'scan',
    page: 'photo-recognize-ai',
    route: '/medicine/search',
    note: '药物图检索结果：AI 识别路径候选列表展开',
    prepare: (tester) async {
      await _showRecognizeDialog(tester, MedicineScanMethod.ai, 'AI 智能识别');
      await tester.tap(find.textContaining('从列表选择其他匹配'));
      await _settle(tester);
    },
  ),
  const _ExtraCapture(
    fileName: '55_auth_login.png',
    group: 'auth',
    page: 'login',
    route: '/login',
    note: '登录页：邮箱凭据登录 + 第三方登录入口（未登录态）',
    signedOut: true,
  ),
  const _ExtraCapture(
    fileName: '56_auth_register.png',
    group: 'auth',
    page: 'register',
    route: '/register',
    note: '注册页：邮箱注册与验证码入口（未登录态）',
    signedOut: true,
  ),
  const _ExtraCapture(
    fileName: '57_auth_forgot-password.png',
    group: 'auth',
    page: 'forgot-password',
    route: '/forgot-password',
    note: '找回密码页：邮箱验证码重置流程入口（未登录态）',
    signedOut: true,
  ),
];

/// A context below both `Localizations` and the app `Navigator`.
///
/// `tester.element(find.byType(LuminousApp))` is the *root* widget element: the
/// `Localizations`/`Navigator` are built inside it, so that context has neither
/// (`showAppDialog` asserts on `Navigator.of(context)`, and
/// `showMedicineBoxScanSheet` reads `AppLocalizations.of(context)!`). The
/// outermost `Navigator`'s own element is equally unusable — it is the navigator
/// itself. Its first child is below both, which is exactly what a real
/// `onPress` callback receives.
BuildContext _hostContext(WidgetTester tester) {
  final navigator = tester.element(find.byType(Navigator).first);
  Element? child;
  navigator.visitChildren((element) => child ??= element);
  final context = child;
  if (context == null) {
    throw StateError(
      'The app Navigator has no child to use as a host context.',
    );
  }
  return context;
}

/// Path of the synthetic medicine-box photo used as the recognition dialog's
/// thumbnail.
///
/// Drawn and encoded at capture time into the system temp directory rather than
/// committed as a binary: the generator stays self-contained, and the "photo" is
/// fixture decoration, not app content.
String get _boxPhotoPath =>
    '${Directory.systemTemp.path}/luminous_screenshot_medicine_box.png';

/// Draws the synthetic box photo to disk if it is not already there.
///
/// Both the PNG encode and the file write are real async work, so this must run
/// inside [WidgetTester.runAsync] — the fake-async zone would never complete it.
Future<void> _ensureBoxPhoto(WidgetTester tester) async {
  final file = File(_boxPhotoPath);
  if (file.existsSync()) return;

  await tester.runAsync(() async {
    const size = ui.Size(480, 480);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final stroke = ui.Paint()
      ..color = const ui.Color(0xFFB2B6BC)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 3;

    // Backdrop, carton body, header band.
    canvas
      ..drawRect(
        ui.Offset.zero & size,
        ui.Paint()..color = const ui.Color(0xFFCED0D4),
      )
      ..drawRRect(
        ui.RRect.fromRectAndRadius(
          const ui.Rect.fromLTRB(40, 90, 440, 390),
          const ui.Radius.circular(18),
        ),
        ui.Paint()..color = const ui.Color(0xFFFAFAFC),
      )
      ..drawRRect(
        ui.RRect.fromRectAndRadius(
          const ui.Rect.fromLTRB(40, 90, 440, 390),
          const ui.Radius.circular(18),
        ),
        stroke,
      )
      ..drawRect(
        const ui.Rect.fromLTRB(43, 93, 437, 178),
        ui.Paint()..color = const ui.Color(0xFFE2E9F5),
      )
      // Product name bar and two text lines.
      ..drawRect(
        const ui.Rect.fromLTRB(70, 210, 410, 258),
        ui.Paint()..color = const ui.Color(0xFF2E58C8),
      )
      ..drawRect(
        const ui.Rect.fromLTRB(70, 282, 340, 312),
        ui.Paint()..color = const ui.Color(0xFF969BA2),
      )
      ..drawRect(
        const ui.Rect.fromLTRB(70, 326, 300, 348),
        ui.Paint()..color = const ui.Color(0xFFB2B6BC),
      )
      // Approval-number block.
      ..drawRect(
        const ui.Rect.fromLTRB(300, 300, 410, 372),
        ui.Paint()..color = const ui.Color(0xFFFFFFFF),
      )
      ..drawRect(
        const ui.Rect.fromLTRB(300, 300, 410, 372),
        ui.Paint()
          ..color = const ui.Color(0xFF787C82)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 2,
      );

    final image = await recorder.endRecording().toImage(480, 480);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) {
      throw StateError('Could not encode the synthetic medicine-box photo.');
    }
    await file.writeAsBytes(data.buffer.asUint8List());
  });
}

/// Opens the real recognition dialog over the current page.
Future<void> _showRecognizeDialog(
  WidgetTester tester,
  MedicineScanMethod method,
  String methodLabel,
) async {
  await _ensureBoxPhoto(tester);

  // `Image.file` decodes through a real async file read, which never completes
  // inside the fake-async test zone — the 60x60 thumbnail would capture blank.
  // Run the decode for real first; the dialog's `Image.file` then hits the
  // populated image cache synchronously.
  final provider = FileImage(File(_boxPhotoPath));
  await tester.runAsync(() => precacheImage(provider, _hostContext(tester)));

  unawaited(
    showAppDialog<void>(
      context: _hostContext(tester),
      barrierDismissible: false,
      scrollable: false,
      builder: (_) => MedicineRecognizeDialog(
        imagePath: _boxPhotoPath,
        method: method,
        methodLabel: methodLabel,
        results: simulatedBoxScanResults(),
        onRetake: () {},
      ),
    ),
  );
  await _settle(tester);
}

void main() {
  final captured = <String>[];
  final renderedTexts = <String, List<String>>{};
  final manifest = StringBuffer()
    ..writeln('# Luminous page-catalog screenshots (generated)')
    ..writeln()
    ..writeln('| File | Group | Page | Route | Text widgets | Note |')
    ..writeln('| --- | --- | --- | --- | --- | --- |');

  setUpAll(() async {
    Directory(_outputDirRelative).createSync(recursive: true);
    _installPlatformStubs();
    await _loadFonts();
  });

  /// Shared capture body: frame, navigate, prime, prepare, dump text, shoot,
  /// record, then unmount and drain before the binding's invariant check.
  Future<void> capture(
    WidgetTester tester, {
    required String fileName,
    required String route,
    AssistantConversation? assistantConversation,
    Future<void> Function(WidgetTester tester)? prepare,
    bool signedOut = false,
    required void Function(int textWidgetCount) record,
  }) async {
    tester.view.physicalSize = const Size(
      _frameWidth * _frameDpr,
      _frameHeight * _frameDpr,
    );
    tester.view.devicePixelRatio = _frameDpr;
    addTearDown(tester.view.reset);

    final container = await _pumpPage(
      tester,
      assistantConversation: assistantConversation,
      signedIn: !signedOut,
    );

    // Navigate by route rather than tapping through the UI: the catalog is
    // ~45 pages, and taps would be far more brittle than `go`.
    final resolved = _resolveRoute(route);
    container.read(appRouterProvider).go(resolved);
    await _settle(tester);

    await _primeRoute(container, tester, resolved);

    if (prepare != null) {
      await prepare(tester);
      await _settle(tester);
    }

    // Record the rendered text instead of asserting on it. The catalog's
    // `expectVisible` strings describe the e2e fixture's copy, which this
    // generator deliberately does not use; the diagnostics below are what
    // proves a page captured populated content rather than a skeleton.
    //
    // Text-field content lives in `EditableText`, not `Text`, so a form that
    // prefill correctly would otherwise look empty here.
    final rendered = <String>[];
    for (final element in find.byType(Text).evaluate()) {
      final data = (element.widget as Text).data;
      if (data != null && data.trim().isNotEmpty) {
        rendered.add(data.trim());
      }
    }
    for (final element in find.byType(EditableText).evaluate()) {
      final data = (element.widget as EditableText).controller.text;
      if (data.trim().isNotEmpty) {
        rendered.add(data.trim());
      }
    }
    renderedTexts[fileName] = rendered;
    record(rendered.length);

    await expectLater(
      find.byType(LuminousApp),
      matchesGoldenFile('$_outputDir/$fileName'),
    );

    captured.add(fileName);

    // Unmount and drain before the binding's end-of-test invariant check.
    // `addTearDown(container.dispose)` runs *after* that check, so several
    // providers (and drift's connection) leave zero-duration timers behind
    // and the case fails with "A Timer is still pending" even though the
    // capture already succeeded.
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    // Pump both a zero-delay step (drains microtask-scheduled timers) and
    // real elapsed time (drains debounce / retry timers) before the
    // binding's end-of-test invariant check.
    await tester.pump(Duration.zero);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 5));
  }

  for (var i = 0; i < catalog.screenshotCatalog.length; i += 1) {
    final target = catalog.screenshotCatalog[i];
    final fileName = catalog.screenshotFileName(i, target);

    testWidgets(
      'generate ${target.group}/${target.id}',
      (tester) => capture(
        tester,
        fileName: fileName,
        route: target.route,
        prepare: target.prepare,
        record: (count) => manifest.writeln(
          '| `$fileName` | ${target.group} | ${target.id} | '
          '`${target.route}` | $count | ${target.note ?? ''} |',
        ),
      ),
      timeout: const Timeout(Duration(seconds: 45)),
    );
  }

  for (final extra in _extraCaptures) {
    testWidgets(
      'generate ${extra.group}/${extra.page}',
      (tester) => capture(
        tester,
        fileName: extra.fileName,
        route: extra.route,
        assistantConversation: extra.assistantConversation,
        prepare: extra.prepare,
        signedOut: extra.signedOut,
        record: (count) => manifest.writeln(
          '| `${extra.fileName}` | ${extra.group} | ${extra.page} | '
          '`${extra.route}` | $count | ${extra.note} |',
        ),
      ),
      timeout: const Timeout(Duration(seconds: 45)),
    );
  }

  tearDownAll(() {
    // Sync I/O only: async file work inside the test zone would need
    // `tester.runAsync` and is not worth the deadlock risk.
    final dir = Directory(_outputDirRelative)..createSync(recursive: true);
    File('${dir.path}/MANIFEST.md').writeAsStringSync(manifest.toString());

    // Per-page text dump: the cheap way to prove a capture is populated rather
    // than a skeleton, an empty state, or an error card.
    final diagnostics = StringBuffer();
    for (final entry in renderedTexts.entries) {
      diagnostics
        ..writeln('=== ${entry.key} (${entry.value.length} text widgets)')
        ..writeln(entry.value.join(' | '))
        ..writeln();
    }
    File(
      '${dir.path}/_rendered_text.txt',
    ).writeAsStringSync(diagnostics.toString());

    // ignore: avoid_print
    print('CAPTURED_TOTAL=${captured.length}');
    // ignore: avoid_print
    print('MANIFEST=${dir.path}/MANIFEST.md');
  });
}
