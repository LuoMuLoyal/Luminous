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
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/app/bootstrap.dart';
import 'package:luminous/app/composition/components/registry.dart'
    show compositionProviderOverrides;
import 'package:luminous/app/composition/customizer/layout_repository.dart'
    show layoutRepositoryProvider;
import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/app/composition/health_event/health_event.dart'
    show healthEventRepositoryProvider;
import 'package:luminous/app/composition/health_sync/health_sync.dart'
    show healthSyncRepositoryProvider;
import 'package:luminous/app/composition/medicine/workspace.dart'
    show medicineWorkspaceRepositoryProvider, reminderRepositoryProvider;
import 'package:luminous/app/composition/mine/mine.dart'
    show mineRepositoryProvider;
import 'package:luminous/app/composition/notification/unread_count.dart'
    show notificationUnreadCountProvider;
import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/app/composition/review/review.dart'
    show reviewDashboardRepositoryProvider;
import 'package:luminous/app/composition/snapshot/legal.dart';
import 'package:luminous/app/composition/snapshot/record.dart';
import 'package:luminous/app/composition/today/today_suggestion.dart'
    show todayRepositoryProvider;
import 'package:luminous/app/router.dart';
import 'package:luminous/core/config/feature_flags.dart'
    show genUiEnabledProvider;
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/assistant/data/repositories/lucent.dart'
    show assistantRepositoryProvider;
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/customizer/domain/repositories/layout.dart';
import 'package:luminous/features/generative/presentation/widgets/slot_preview.dart';
import 'package:luminous/features/medicine/data/repositories/relations.dart'
    show medicineRelationsRepositoryProvider;
import 'package:luminous/features/medicine/data/repositories/risk_check.dart'
    show medicineRiskCheckRepositoryProvider;
import 'package:luminous/features/medicine/presentation/providers/medicine_detail.dart'
    show medicineDetailProvider;
import 'package:luminous/features/medicine/presentation/providers/reminders.dart'
    show
        medicineReminderDeliveryLogProvider,
        medicineReminderListProvider,
        medicineTodayDoseLogsProvider;
import 'package:luminous/features/mine/presentation/providers/sync_failures.dart'
    show mineSyncFailedEntriesProvider;
import 'package:luminous/features/notification/data/repositories/lucent.dart'
    show notificationRepositoryProvider;
import 'package:luminous/features/review/presentation/providers/dashboard.dart'
    show reviewDashboardProvider;
import 'package:luminous/features/review/presentation/providers/review.dart'
    show reviewCurrentProvider, reviewHistoryProvider;
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/presentation/pages/box_scan.dart'
    show showMedicineBoxScanSheet;
import 'package:luminous/features/scan/presentation/providers/data_access.dart'
    show scanRepositoryProvider;
import 'package:luminous/features/scan/presentation/widgets/dialogs/recognize_dialog.dart'
    show MedicineRecognizeDialog;
import 'package:luminous/features/search/presentation/providers/data_access.dart'
    show medicineSearchRepositoryProvider;
import 'package:luminous/features/search/presentation/providers/medicine_search.dart'
    show medicineSearchNotifierProvider;
import 'package:luminous/features/settings/data/repositories/lucent.dart'
    show userSettingsRepositoryProvider;
import 'package:luminous/features/support/data/repositories/lucent.dart'
    show supportRepositoryProvider;
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/shared/domain/composition/id.dart';
import 'package:luminous/shared/domain/composition/layout.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

import '../../integration_test/screenshots/page_catalog_screenshot_test.dart'
    as catalog;
import '../../test/helpers/kv_test_store.dart';
import 'simulated_fakes_assistant.dart';
import 'simulated_fakes_graph.dart';
import 'simulated_fakes_health_event.dart';
import 'simulated_fakes_misc.dart';
import 'simulated_fakes_review.dart';
import 'simulated_fakes_shell_a.dart';
import 'simulated_fakes_shell_b.dart';

// ── Frame ───────────────────────────────────────────────────────────────────

/// A capture frame: logical size + pixel density.
typedef _Frame = ({double width, double height, double dpr});

/// Pixel 8 Pro: 1344x2992 physical at density 480 (dpr 3).
const _Frame _phoneFrame = (width: 448, height: 2992 / 3, dpr: 3);

/// Desktop window: 1280x800 logical at dpr 2 (2560x1600 physical).
///
/// 1280 落在 M3 `large` 档（≥1200），桌面布局的侧边栏、双栏、右侧面板都会出现。
/// dpr 2 而不是 3：桌面屏幕的物理密度本来就低，dpr 3 只会得到一张
/// 3840x2400 的巨型 PNG，评审时缩放看反而更糊。
const _Frame _desktopFrame = (width: 1280, height: 800, dpr: 2);

/// 当前用例使用的帧。由各 testWidgets 在开跑前设置。
_Frame _frame = _phoneFrame;

double get _frameWidth => _frame.width;
double get _frameHeight => _frame.height;
double get _frameDpr => _frame.dpr;

/// Capture directory; the golden comparator resolves this against this file.
const String _outputDir = '../../outputs/screenshots';

/// Project-relative form of [_outputDir], for the manifest write.
const String _outputDirRelative = 'outputs/screenshots';

/// 长截图单独一个目录：它们的高度和常规帧差一个数量级，混在页面目录里会
/// 让「按页面浏览」失效。
const String _longDir = 'long';

/// 长截图的像素密度。
///
/// 常规帧是 dpr 3；整页截图动辄 4000+ 逻辑像素，按 dpr 3 会得到一万多像素
/// 高、单张几 MB 的图。降到 2 后文字仍然清晰，体积减半以上。
const double _longDpr = 2;

/// 长截图的最大逻辑高度，超出则截断。
///
/// 这是防呆上限，不是设计目标：真出现这么高的页面说明布局有问题，值得
/// 在评审时看到「被截断」而不是生成一张打不开的图。
const double _longMaxHeight = 8000;

/// 一级页（五个 tab 根页）所在的分组。
const String _shellGroup = 'shell';

/// 二级页所属的 tab 分组：这些页面归到各自 tab 目录，并以 `2_` 开头，
/// 与一级页（`1_`）在同一目录里天然排序分开。
const Set<String> _tabGroups = {
  'today',
  'record',
  'medicine',
  'review',
  'mine',
};

/// 一条产物在输出目录中的落点。
typedef _Placement = ({String folder, String prefix});

/// 决定一条产物放哪个子目录、文件名加什么前缀。
///
/// 规则（对应用户要的「按 tab 分一级/二级页」）：
/// - 五个 tab 根页（`shell` 组）→ 各自的 tab 目录，前缀 `1_`；
/// - 某个 tab 的子页面 → 同目录，前缀 `2_`；
/// - 其它分组（settings / auth / scan / …）→ 独立目录，不加前缀。
_Placement _placementFor(String group, String id) {
  if (group == _shellGroup) return (folder: id, prefix: '1_');
  if (_tabGroups.contains(group)) return (folder: group, prefix: '2_');
  return (folder: group, prefix: '');
}

/// golden 路径：比较器以本文件所在目录为基准解析。
String _goldenPath(String folder, String name) => '$_outputDir/$folder/$name';

/// 建目录用项目根相对路径：`flutter test` 的工作目录就是项目根。
void _ensureOutputDir(String folder) {
  Directory('$_outputDirRelative/$folder').createSync(recursive: true);
}

/// 长截图的文件名：`long/<folder>__<name>.png`。
String _longName(String folder, String name) =>
    '${folder.replaceAll('/', '_')}__$name.png';

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
      'getSize' => <double>[_frameWidth, _frameHeight],
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

  // 本地库（drift + SQLCipher）的密钥来自安全存储。没有这个桩时
  // `DatabaseKeyProvider` 抛 `MissingPluginException`，drift 打开失败，
  // bootstrap 里的缓存清理把这个失败作为**未捕获异常**抛进测试，
  // 整页截图虽然已经写出，用例仍然判失败。
  //
  // 这里给一个固定的密钥：截图不需要真实加密强度，只需要可重复、能开库。
  //
  // **必须按 key 名精确返回**：同一个通道也被会话存储用来读 token payload，
  // 对所有 key 都返回数据库密钥会让会话反序列化报 FormatException 并把登录态
  // 打回未登录——那样截出来的是登录页。
  const dbKey = 'c2NyZWVuc2hvdC1nZW5lcmF0b3ItZGIta2V5LTMyYnl0ZXM=';
  const dbKeyName = 'luminous.db.key';
  messenger.setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (call) async {
      final args = call.arguments;
      final key = args is Map ? args['key'] : null;
      return switch (call.method) {
        'read' => key == dbKeyName ? dbKey : null,
        'readAll' => <String, String>{dbKeyName: dbKey},
        'containsKey' => key == dbKeyName,
        'write' || 'delete' || 'deleteAll' => null,
        _ => null,
      };
    },
  );

  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/package_info'),
    (call) async => call.method == 'getAll'
        ? <String, Object?>{
            'appName': 'Luminous',
            'packageName': 'com.devluo.luminous',
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

/// 演示用的用药页布局：默认四张卡 + **全部十个关系图组件**。
///
/// 十个图组件在生产里默认不挂载（见 `medicine/presentation/components/catalog.dart`
/// 的注释：五个需要入参、且都依赖 health_context 快照）。截图要展示它们，
/// 所以这里给出一份"用户自己编排出来的用药安全工作台"，顺序即阅读顺序：
/// 风险检查 → 组合概览 → 机制/靶点/级联 → 单药类 → 需要入参的那几个。
///
/// 这份布局同时是「组件化编排真实生效」的证据：截出来的页面不是手写页面，
/// 而是 `ComponentHost` 按 `SurfaceLayout` 渲染的结果。
const _medicineWorkbenchLayout = SurfaceLayout(
  placements: [
    ComponentPlacement(id: ComponentId('drug_box.inventory')),
    ComponentPlacement(id: ComponentId('dose.records')),
    ComponentPlacement(id: ComponentId('dose.safety_engine')),
    ComponentPlacement(id: ComponentId('quick_action.medicine')),
    ComponentPlacement(id: ComponentId('dose.medication_overview')),
    ComponentPlacement(id: ComponentId('dose.mechanism_paths')),
    ComponentPlacement(id: ComponentId('dose.shared_targets')),
    ComponentPlacement(id: ComponentId('dose.cascade_paths')),
    ComponentPlacement(id: ComponentId('dose.enzyme_duels')),
    ComponentPlacement(id: ComponentId('dose.drug_actions')),
    ComponentPlacement(id: ComponentId('dose.transport_routes')),
    ComponentPlacement(id: ComponentId('dose.substitutes')),
    ComponentPlacement(id: ComponentId('dose.shortest_routes')),
    ComponentPlacement(id: ComponentId('dose.target_drugs')),
  ],
);

/// 今日页 + 已生成的 `generative.today` 组件。
///
/// 复用默认布局的顺序，只在摘要之后插入生成式格子——这正是用户打开实验
/// 开关、点「生成」之后会看到的形态。
const _generativeTodayLayout = SurfaceLayout(
  placements: [
    ComponentPlacement(id: ComponentId('daily.greeting')),
    ComponentPlacement(id: ComponentId('suggestion.primary')),
    ComponentPlacement(id: ComponentId('generative.today')),
    ComponentPlacement(id: ComponentId('summary.metrics')),
    ComponentPlacement(id: ComponentId('observation.metrics')),
    ComponentPlacement(id: ComponentId('quick_action.strip')),
  ],
);

/// 只读布局仓储：把上面那份演示布局交给 app。
///
/// 不读 KV 也不发网络：截图不需要"用户改布局"的能力，只需要一个确定的起点。
class _SimulatedLayoutRepository implements LayoutRepository {
  const _SimulatedLayoutRepository(this.layouts);

  final Map<SurfaceId, SurfaceLayout> layouts;

  @override
  TaskEither<LucentFailure, Map<SurfaceId, SurfaceLayout>> readAll() =>
      TaskEither.right(layouts);

  @override
  TaskEither<LucentFailure, SurfaceLayout> write(
    SurfaceId surface,
    SurfaceLayout layout, {
    int? ifVersion,
  }) => TaskEither.right(layout);
}

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
  bool desktopChrome = false,
  // 打开实验开关并注入一份已生成的 surface 消息，用于截「生成式 UI」。
  bool generative = false,
}) async {
  // ignore: invalid_use_of_visible_for_testing_member -- this file is a test-run generator.
  KvTestStore.install(seed: const <String, Object>{});
  final prefs = KvStore.instance;
  await prefs.clear();
  await prefs.set('app.locale', 'zh-CN');

  if (generative) {
    // `genui.<surface>.spec`：用户自定义区块的**声明**（标题 + 让 agent
    // 渲染什么）。编排页那一行据此显示用户填的名字，而不是通用的「尚未配置」。
    //
    // **不写生成结果**（`genui.<surface>.surface`）：生成内容的渲染依赖一次
    // 真实异步读取，而 `flutter_test` 的假时钟推不动它（详见
    // `_pumpPage` 里 `generative` 参数的说明），在截图流程里无法稳定复现。
    // 页面截图因此不在本生成器的覆盖范围内——它属于 widget 测试的领域。
    await prefs.set(
      'genui.today.spec',
      jsonEncode({'title': '本周饮水与睡眠', 'prompt': '把本周的饮水量和睡眠时长做成两张并排的小卡'}),
    );
  }

  const healthContext = SimulatedHealthContextRepository();

  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      // ── 组件化装配根 ──────────────────────────────────────────────
      //
      // **没有这一条，所有 tab 页的内容区都是空的。**
      //
      // tab 页的内容不再是手写 Column，而是 `ComponentHost` 按
      // `surfaceLayoutProvider(SurfaceId.x)` 渲染。那个 provider 默认为
      // "空 catalog ⇒ 空布局"，真实定义与注册表由组合根在
      // `compositionProviderOverrides()` 里注入（`main.dart` 通过
      // `buildRootContainer()` 做这件事）。本生成器自建容器，若不同样注入，
      // 每个页面的内容区就渲染 0 个组件——截图看起来像"页面没内容"，
      // 实际是装配缺失。
      ...compositionProviderOverrides(),

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

      // 关系图十个端点 + 用药组合概览的模拟实现。
      medicineRelationsRepositoryProvider.overrideWithValue(
        const SimulatedMedicineRelationsRepository(),
      ),

      // 今日页「健康观察」：不接这个仓储时整块渲染成「暂不可用，请重试」。
      healthEventRepositoryProvider.overrideWithValue(
        const SimulatedHealthEventRepository(),
      ),

      // 布局仓储：给用药页一份挂了全部十个图组件的布局，这样截出来的
      // 用药页就是"用户编排出来的安全工作台"，同时证明组件化真的在驱动渲染。
      // 其余 surface 返回空 map ⇒ 走各自的 defaultLayout（与改造前一致）。
      layoutRepositoryProvider.overrideWithValue(
        _SimulatedLayoutRepository({
          SurfaceId.medicine: _medicineWorkbenchLayout,
          if (generative) SurfaceId.today: _generativeTodayLayout,
        }),
      ),
      // 生成式 UI 由实验开关控制（默认 false）。关闭时 `generative.<surface>`
      // 根本不注册，布局里提到它也只是被跳过——所以截图必须先开这个开关。
      genUiEnabledProvider.overrideWith((ref) => generative),
      // 生成结果的真实渲染要经过一次异步 KV 恢复，`flutter_test` 的假时钟
      // 推不动真实 Future（详见 `capture` 里的注释）。截图改用等价的手绘预览：
      // 同样是三张并排小卡，形状与生成结果一致。
      generativeSlotPreviewProvider.overrideWith((ref) => generative),
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
      // review 的 dashboard 数据：生成式 UI 的领域 item（`trendChart` /
      // `metricCard` / `finding`）都从 `reviewSurfaceStateProvider` 取真值，
      // 而它最终落到这个 family。不覆盖就走真实网络，`trendChart` 拿不到
      // 数据会**静默返回空**（渲染一截空白，不报错），截图里那块地方看起来
      // 就像什么都没生成。
      reviewDashboardProvider.overrideWith(
        (ref, query) async =>
            (await const SimulatedReviewDashboardRepository()
                    .fetchDashboard(query)
                    .run())
                .fold((failure) => throw failure, (dashboard) => dashboard),
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
    UncontrolledProviderScope(
      container: container,
      // 桌面档需要窗口 chrome 一起入镜（标题栏按钮、拖拽区），
      // 手机档不渲染它，否则截图里会混进最小化/最大化/关闭。
      child: LuminousApp(desktopChrome: desktopChrome),
    ),
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

/// 产物帧的类别标注，写进 manifest。
String _frameKindLabel(String relativePath) {
  if (relativePath.startsWith('$_longDir/')) return ' (长截图)';
  if (relativePath.endsWith('_scrolled.png')) return ' (滚动后)';
  return '';
}

/// 把主滚动视图挪到 [fraction] 处，返回是否真的滚动了。
///
/// ## 为什么自己找滚动视图
///
/// 页面形态不一：tab 页是 `CustomScrollView`，表单页是 `ListView`，
/// 弹层里还有各自的 `Scrollable`。`find.byType(Scrollable).first` 经常命中
/// 横向条或嵌套列表。这里取 `maxScrollExtent` 最大的那个——它就是**页面
/// 主滚动方向**，也是「往下翻」这个动作在用户眼里的含义。
///
/// ## 为什么用 drag 而不是 `position.jumpTo`
///
/// `jumpTo` 直接改滚动位置，绕过了手势与滚动物理；在有嵌套 sliver 的页面上
/// 会把已经进入销毁流程的 `RenderViewport` 再拉去 layout，触发
/// 「RenderViewport DISPOSED」断言（记录页就是这么挂的）。`tester.drag` 走的是
/// 真实手势链路，滚动由 `Scrollable` 自己应用，不会和 layout 抢时序。
///
/// 没有可滚动内容时返回 false，调用方据此跳过第二帧：短页面不该产出
/// 与首屏一模一样的重复图。
Future<bool> _scrollPageToFraction(WidgetTester tester, double fraction) async {
  Element? primaryElement;
  var bestExtent = 0.0;
  for (final element in find.byType(Scrollable).evaluate()) {
    if (element is! StatefulElement) continue;
    final state = element.state;
    if (state is! ScrollableState) continue;
    final position = state.position;
    if (!position.hasContentDimensions) continue;
    // **只认纵向滚动**。记录页顶部的横向日期条也可能有更大的
    // `maxScrollExtent`，而「往下翻」对它没有意义：一旦选中它，
    // 垂直拖拽会被横向手势识别器抢走并触发 `DragUpdateDetails` 断言。
    if (position.axis != Axis.vertical) continue;
    if (position.maxScrollExtent > bestExtent) {
      bestExtent = position.maxScrollExtent;
      primaryElement = element;
    }
  }
  if (primaryElement == null || bestExtent <= 0) return false;

  final distance = (bestExtent * fraction).clamp(0.0, bestExtent);
  if (distance <= 0) return false;

  final anchor = find.byElementPredicate((e) => identical(e, primaryElement));
  if (anchor.evaluate().isEmpty) return false;

  // 起手点取滚动区域的中下部，而不是默认的几何中心：记录页顶部有一条横向
  // 日期条，从中心起手仍可能压到它上面，垂直拖拽的指针事件会被
  // `DragUpdateDetails` 的一致性断言拦下（primaryDelta 与 delta 不匹配）。
  // 往页面靠下的位置起手，能稳定落在页面主体的纵向列表上。
  final rect = tester.getRect(anchor);
  final startPoint = Offset(rect.center.dx, rect.top + rect.height * 0.7);

  // 手势路径上的失败是**逐页的**，不该让整张截图判失败。这里临时接管
  // `FlutterError.onError`，把滚动过程中的框架错误收集起来；只要发生了一条，
  // 就放弃这一页的滚动帧——首屏截图已经成功，证据不受损。
  final scrollErrors = <FlutterErrorDetails>[];
  final previousOnError = FlutterError.onError;
  FlutterError.onError = scrollErrors.add;
  try {
    await tester.dragFrom(startPoint, Offset(0, -distance));
    await tester.pump();
    await _settle(tester);
  } catch (_) {
    return false;
  } finally {
    FlutterError.onError = previousOnError;
  }
  if (scrollErrors.isNotEmpty) return false;
  return true;
}

/// 主滚动视图的内容总高度（逻辑像素）；无纵向滚动时返回 null。
///
/// `maxScrollExtent + viewportDimension` 就是「整页」的高度：首屏之外那部分
/// 加上已经显示的一屏。长截图把这个值当成帧高，一次性把整页画出来。
double? _pageContentHeight(WidgetTester tester) {
  var best = 0.0;
  for (final element in find.byType(Scrollable).evaluate()) {
    if (element is! StatefulElement) continue;
    final state = element.state;
    if (state is! ScrollableState) continue;
    final position = state.position;
    if (!position.hasContentDimensions) continue;
    if (position.axis != Axis.vertical) continue;
    final total = position.maxScrollExtent + position.viewportDimension;
    if (total > best) best = total;
  }
  return best > 0 ? best : null;
}

/// 把主滚动视图拉回顶部。
///
/// 长截图必须从顶部开始，否则会把「当前滚动位置」以上那一段裁掉。
/// 目标偏移 0 永远是合法值，所以这里可以直接 `jumpTo`，不存在
/// [_scrollPageToFraction] 里「目标落在已销毁 viewport」的问题。
void _scrollPageToTop(WidgetTester tester) {
  ScrollableState? primary;
  var best = 0.0;
  for (final element in find.byType(Scrollable).evaluate()) {
    if (element is! StatefulElement) continue;
    final state = element.state;
    if (state is! ScrollableState) continue;
    final position = state.position;
    if (!position.hasContentDimensions) continue;
    if (position.axis != Axis.vertical) continue;
    if (position.maxScrollExtent > best) {
      best = position.maxScrollExtent;
      primary = state;
    }
  }
  primary?.position.jumpTo(0);
}

// ── Extra surfaces ──────────────────────────────────────────────────────────
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

  // ── 回顾页：多维度趋势图的三个维度 ─────────────────────────────
  //
  // 「健康趋势」是同一张折线图按维度切换（用药完成率 / 饮水 / 睡眠）。
  // 单张 at-rest 截图只能看到默认维度，另外两个必须点 tab 才出现；
  // 三者一起才是「多维度」的证据。
  _ExtraCapture(
    fileName: '58_review_trend-medication.png',
    group: 'review',
    page: 'trend-medication',
    route: '/review',
    note: '回顾 · 健康趋势（用药完成率维度）',
    prepare: (tester) async {
      await _scrollToReviewTrend(tester);
    },
  ),
  _ExtraCapture(
    fileName: '59_review_trend-water.png',
    group: 'review',
    page: 'trend-water',
    route: '/review',
    note: '回顾 · 健康趋势（饮水维度）',
    prepare: (tester) async {
      await _scrollToReviewTrend(tester);
      await tester.tap(find.text('饮水').last);
      await _settle(tester);
    },
  ),
  _ExtraCapture(
    fileName: '60_review_trend-sleep.png',
    group: 'review',
    page: 'trend-sleep',
    route: '/review',
    note: '回顾 · 健康趋势（睡眠维度）',
    prepare: (tester) async {
      await _scrollToReviewTrend(tester);
      await tester.tap(find.text('睡眠').last);
      await _settle(tester);
    },
  ),

  // ── 用药页：切到「图」视图后的样子 ───────────────────────────
  //
  // 列表/图是两个变体，但默认截出来只有列表。若不专门拍，`graphview` 的分层图
  // 在整个产物集里没有任何证据——它坏了也不会有人发现。
  _ExtraCapture(
    fileName: '61_medicine_graph-view-mechanism.png',
    group: 'medicine',
    page: 'graph-view-mechanism',
    route: '/medicine',
    note: '用药 · 机制通路的图视图（Sugiyama 分层）',
    prepare: (tester) async {
      await _toggleGraphView(tester, last: false);
    },
  ),
  _ExtraCapture(
    fileName: '62_medicine_graph-view-cascade.png',
    group: 'medicine',
    page: 'graph-view-cascade',
    route: '/medicine',
    note: '用药 · 级联传播的图视图（四跳链）',
    prepare: (tester) async {
      await _toggleGraphView(tester, last: true);
    },
  ),

  // ── 同步失败页：单条展开诊断信息 ─────────────────────────────
  //
  // 列表态是默认态，展开态才是排查时真正读的那一屏：诊断面板里的
  // wire 字段、trace、原始异常只在这里出现，不专门截就没有证据。
  _ExtraCapture(
    fileName: '63_mine_sync-failures-diagnostics.png',
    group: 'mine',
    page: 'sync-failures-diagnostics',
    route: '/mine/sync/failures',
    note: '同步失败 · 首条展开诊断信息（wire 字段、trace、原始异常与复制入口）',
    prepare: (tester) async {
      final toggle = find
          .byKey(const Key('sync-failed-entry-diagnostics'))
          .first;
      await tester.ensureVisible(toggle);
      await _settle(tester);
      await tester.tap(toggle);
      await _settle(tester);
      await tester.ensureVisible(toggle);
      await _settle(tester);
    },
  ),
];

/// 把关系图卡切到「图」视图，并滚到它进入视口。
///
/// [last] 为真时取最后一个切换钮（级联），否则取第一个（机制通路）。
/// 切换钮是图标按钮，语义标签在 `Semantics` 上，所以按 Key 找更稳。
Future<void> _toggleGraphView(WidgetTester tester, {required bool last}) async {
  final toggles = find.byKey(const Key('medicine-graph-view-toggle'));
  if (toggles.evaluate().isEmpty) return;
  final target = last ? toggles.last : toggles.first;
  await tester.ensureVisible(target);
  await _settle(tester);
  await tester.tap(target);
  await _settle(tester);
  // 图卡片比列表高，再滚一次让它整体进入视口。
  await tester.ensureVisible(target);
  await _settle(tester);
}

/// 滚到回顾页的「健康趋势」标题处，让趋势图进入视口。
///
/// 趋势区块在回顾页很靠下，且切换维度的 tab 必须**可见**才能点中
/// （tap 会对屏幕外的点报 warnIfMissed）。这里直接把主滚动视图滚到底：
/// 趋势图是页面的最后一块。
Future<void> _scrollToReviewTrend(WidgetTester tester) async {
  final scrollables = find.byType(Scrollable).evaluate();
  Element? deepest;
  var best = 0.0;
  for (final element in scrollables) {
    if (element is! StatefulElement) continue;
    final state = element.state;
    if (state is! ScrollableState) continue;
    final position = state.position;
    if (!position.hasContentDimensions) continue;
    if (position.axis != Axis.vertical) continue;
    if (position.maxScrollExtent > best) {
      best = position.maxScrollExtent;
      deepest = element;
    }
  }
  if (deepest == null || best <= 0) return;
  final anchor = find.byElementPredicate((e) => identical(e, deepest));
  if (anchor.evaluate().isEmpty) return;
  final rect = tester.getRect(anchor);
  await tester.dragFrom(
    Offset(rect.center.dx, rect.top + rect.height * 0.7),
    Offset(0, -best),
  );
  await tester.pump();
  await _settle(tester);
}

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
      // `DialogShell` 断言禁止「scrollable: false 且没有 maxHeight」：内容一旦
      // 高于弹窗上限就会静默溢出底边。识别结果列表是可变长的，这里给有界高度；
      // 保留 `scrollable: false` 是因为列表自己要滚，外层滚动层会和它抢手势。
      scrollable: false,
      maxHeight: _frameHeight * 0.85,
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
    ..writeln('目录结构：每个 tab 一个目录，`1_*` 是 tab 根页（一级），`2_*` 是')
    ..writeln('该 tab 的子页面（二级）；`*_scrolled.png` 是滚到中段的第二帧；')
    ..writeln('`long/` 放所有整页长截图。')
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
  ///
  /// 每个页面最多产出三帧：
  /// 1. `<folder>/<name>.png` — 首屏；
  /// 2. `<folder>/<name>_scrolled.png` — 滚动到中段（仅当内容溢出）；
  /// 3. `long/<folder>__<name>.png` — 整页长截图（仅当内容溢出）。
  Future<void> capture(
    WidgetTester tester, {
    required _Placement placement,
    required String name,
    required String route,
    AssistantConversation? assistantConversation,
    Future<void> Function(WidgetTester tester)? prepare,
    bool signedOut = false,
    bool longCapture = true,
    bool scrolledCapture = true,
    // 桌面档：1280x800 + 窗口 chrome。默认手机档，行为与改动前一致。
    bool desktop = false,
    // 打开实验开关 + 注入一份已生成的 surface 消息，用于截生成式 UI。
    bool generative = false,
    required void Function(String relativePath, int textWidgetCount) record,
  }) async {
    _frame = desktop ? _desktopFrame : _phoneFrame;
    final folder = placement.folder;
    final baseName = '${placement.prefix}$name';
    _ensureOutputDir(folder);

    tester.view.physicalSize = Size(
      _frameWidth * _frameDpr,
      _frameHeight * _frameDpr,
    );
    tester.view.devicePixelRatio = _frameDpr;
    addTearDown(tester.view.reset);

    final container = await _pumpPage(
      tester,
      assistantConversation: assistantConversation,
      signedIn: !signedOut,
      desktopChrome: desktop,
      generative: generative,
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

    // 生成式 UI 的冷启动恢复是异步的：`GenerativeSurfaceNotifier.build`
    // 先同步返回 `Idle`（不占位），再 await 一次缓存读取把状态推成 `Ready`。
    // `_settle` 在「当前没有待调度帧」时就返回，正好会卡在 Idle 与 Ready 之间，
    // 于是截到的是空态入口而不是重放出来的消息。这里显式多推几轮，让那次
    // 异步读取与其后的 setState 都落定。
    if (generative) {
      // 生成式区块的**声明**写进 KV 后，编排页那一行要等一次异步读取才显示
      // 用户填的名字。这里多推几轮让那次读取落定，否则截到的是「尚未配置」。
      //
      // 注意：这里**不等生成内容**。生成结果的渲染依赖一次真实异步读取，
      // `flutter_test` 的假时钟推不动它（`pump` 不推进真实 Future），在截图
      // 流程里无法稳定复现——页面侧的生成内容属于 widget 测试的领域，见
      // `test/generative/generative_surface_test.dart`。
      await _settle(tester);
      for (var i = 0; i < 12; i += 1) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    // Record the rendered text instead of asserting on it. The catalog's
    // `expectVisible` strings describe the e2e fixture's copy, which this
    // generator deliberately does not use; the diagnostics below are what
    // proves a page captured populated content rather than a skeleton.
    //
    // Text-field content lives in `EditableText`, not `Text`, so a form that
    // prefill correctly would otherwise look empty here.
    void dumpRendered(String relativePath) {
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
      renderedTexts[relativePath] = rendered;
      record(relativePath, rendered.length);
    }

    final firstFrame = '$folder/$baseName.png';
    dumpRendered(firstFrame);

    await expectLater(
      find.byType(LuminousApp),
      matchesGoldenFile(_goldenPath(folder, '$baseName.png')),
    );

    captured.add(firstFrame);

    // ── 滚动后的第二帧 ──────────────────────────────────────────────
    //
    // 此前每个页面只截首屏，标题以下的内容全部看不见：用药页新增的十个
    // 关系图卡片、回顾页的趋势区块、我的页的下半部分都不在证据范围内。
    // 这里对**内容确实溢出**的页面再截一帧中段画面。
    //
    // 判据是主滚动视图的 `maxScrollExtent > 0`：短页面（表单、弹层）没有
    // 可滚动内容，就不产出多余的重复图。
    //
    // 桌面档不产出这一帧（`scrolledCapture`）：它证明的是「内容溢出一屏」，
    // 而桌面上这个结论本身就是要看的信号——如果五个 tab 在 1280×800 下
    // 仍然全部溢出，说明布局还没有利用宽屏，评审时应当直接看到「只有首屏
    // 一张图」，而不是被同名的第二帧稀释掉这个信号。
    if (scrolledCapture) {
      final everScrolled = await _scrollPageToFraction(tester, 0.55);
      if (everScrolled) {
        final scrolledFrame = '$folder/${baseName}_scrolled.png';
        dumpRendered(scrolledFrame);
        await expectLater(
          find.byType(LuminousApp),
          matchesGoldenFile(_goldenPath(folder, '${baseName}_scrolled.png')),
        );
        captured.add(scrolledFrame);
      }
    }

    // ── 整页长截图 ──────────────────────────────────────────────────
    //
    // 把帧高临时拉到「内容总高」，一次性画出整页：这是「这个页面到底有多长、
    // 中段和尾部各是什么」最省事的证据，也避免滚动帧只能覆盖中段的偶然性。
    //
    // 只在内容确实溢出时产出；高度封顶 [_longMaxHeight]，防止异常布局
    // 生成一张打不开的图。
    final contentHeight = _pageContentHeight(tester);
    if (longCapture &&
        contentHeight != null &&
        contentHeight > _frameHeight * 1.05) {
      _scrollPageToTop(tester);
      await tester.pump();
      final longHeight = contentHeight.clamp(_frameHeight, _longMaxHeight);
      tester.view.physicalSize = Size(
        _frameWidth * _longDpr,
        longHeight * _longDpr,
      );
      tester.view.devicePixelRatio = _longDpr;
      await tester.pump();
      await _settle(tester);

      final longFile = '$_longDir/${_longName(folder, baseName)}';
      _ensureOutputDir(_longDir);
      dumpRendered(longFile);
      await expectLater(
        find.byType(LuminousApp),
        matchesGoldenFile(_goldenPath(_longDir, _longName(folder, baseName))),
      );
      captured.add(longFile);

      // 还原常规帧，后面的 teardown 与其它断言都按原尺寸走。
      tester.view.physicalSize = Size(
        _frameWidth * _frameDpr,
        _frameHeight * _frameDpr,
      );
      tester.view.devicePixelRatio = _frameDpr;
      await tester.pump();
    }

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

  // ── 桌面档：五个 tab 根页 ────────────────────────────────────────────
  //
  // 1280x800 落在 M3 `large` 档，侧边栏、分组、三层底色与桌面密度全部出现。
  // 输出到 `desktop/` 子目录，与手机档的 tab 目录分开——同一个页面在两个
  // 尺寸下的表现差异，正是这一档要看的证据。
  //
  // 不产出 `_scrolled` 与长截图：桌面内容区一次能容纳更多，滚动帧的价值
  // 低于手机档；而 1280x800 的整页长截图会得到一张高度远超宽度的怪图。
  for (final target in catalog.screenshotCatalog.where(
    (t) => t.group == _shellGroup,
  )) {
    testWidgets(
      'generate desktop/${target.id}',
      (tester) => capture(
        tester,
        desktop: true,
        placement: (folder: 'desktop', prefix: ''),
        name: target.id,
        route: target.route,
        prepare: target.prepare,
        longCapture: false,
        scrolledCapture: false,
        record: (name, count) => manifest.writeln(
          '| `$name` | ${target.group} | ${target.id} | '
          '`${target.route}` | $count | desktop 1280x800${_frameKindLabel(name)} |',
        ),
      ),
      timeout: const Timeout(Duration(seconds: 45)),
    );
  }

  // ── 桌面档：全部二级页 ──────────────────────────────────────────────
  //
  // 手机档里的每一个二级页，在桌面档都有对应的一张。文件名带分组前缀
  // （`<group>-<id>`），避免与一级页在同一个 `desktop/` 目录里重名。
  //
  // 这一档的价值不在「和手机档长得一样」，而在它暴露的问题：内容列是否与
  // 桌面壳对齐、长文行宽是否越过阅读上限、表单是否还在贴边。曾经的
  // `maxContentWidth`（桌面档 1600，而窗口只有 1280）就是被这一档看出来的
  // ——上限从未生效，二级页比一级页的内容宽出 200 余像素。
  for (final target in catalog.screenshotCatalog.where(
    (t) => t.group != _shellGroup,
  )) {
    final fileName = '${target.group}-${target.id}';
    testWidgets(
      'generate desktop/$fileName',
      (tester) => capture(
        tester,
        desktop: true,
        placement: (folder: 'desktop', prefix: ''),
        name: fileName,
        route: target.route,
        prepare: target.prepare,
        longCapture: false,
        scrolledCapture: false,
        record: (name, count) => manifest.writeln(
          '| `$name` | ${target.group} | ${target.id} | '
          '`${target.route}` | $count | desktop 1280x800（二级页）'
          '${_frameKindLabel(name)} |',
        ),
      ),
      timeout: const Timeout(Duration(seconds: 45)),
    );
  }

  for (var i = 0; i < catalog.screenshotCatalog.length; i += 1) {
    final target = catalog.screenshotCatalog[i];
    final placement = _placementFor(target.group, target.id);

    testWidgets(
      'generate ${target.group}/${target.id}',
      (tester) => capture(
        tester,
        placement: placement,
        name: target.id,
        route: target.route,
        prepare: target.prepare,
        record: (name, count) => manifest.writeln(
          '| `$name` | ${target.group} | ${target.id} | '
          '`${target.route}` | $count | ${target.note ?? ''}'
          '${_frameKindLabel(name)} |',
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
        placement: _placementFor(extra.group, extra.page),
        name: extra.fileName.replaceAll('.png', ''),
        route: extra.route,
        assistantConversation: extra.assistantConversation,
        prepare: extra.prepare,
        signedOut: extra.signedOut,
        // extras 是「同一条路由的某个特定状态」，整页长截图会在同一路由上
        // 重复产出内容几乎相同的图（趋势的三个维度就是这样）。它们的价值
        // 在首屏那一帧，不产出长截图。
        longCapture: false,
        record: (name, count) => manifest.writeln(
          '| `$name` | ${extra.group} | ${extra.page} | '
          '`${extra.route}` | $count | ${extra.note}'
          '${_frameKindLabel(name)} |',
        ),
      ),
      timeout: const Timeout(Duration(seconds: 45)),
    );
  }

  // ── 生成式 UI（实验开关打开）──────────────────────────────────────
  //
  // 生成式组件默认不出现：开关关闭时 `generative.<surface>` 根本不注册，
  // 打开但没生成过时 `GenerativeSurface` 返回 null 不占位。所以这一张必须
  // **同时**做三件事——开开关、写一份已生成的 KV 文档、把组件挂进布局。
  //
  // 手机与桌面各一张：生成式结果是流式消息重放出来的，两端都要能看。
  // 编排页上的自定义区块：那一行的名字是用户填的标题，尾部的笔形按钮是
  // 配置入口。这一张要证明的是「配置发生在编排页、而不是页面上」。
  testWidgets(
    'generate genui-customizer',
    (tester) => capture(
      tester,
      generative: true,
      placement: (folder: 'generative', prefix: ''),
      name: 'genui-customizer',
      route: '/customize/today',
      longCapture: false,
      scrolledCapture: false,
      record: (name, count) => manifest.writeln(
        '| `$name` | generative | customize/today | '
        '`/customize/today` | $count | 编排页：自定义生成式区块的名称与编辑入口'
        '${_frameKindLabel(name)} |',
      ),
    ),
    timeout: const Timeout(Duration(seconds: 45)),
  );

  // 生成式区块在页面上的形态：三张并排的小卡。
  //
  // 与编排页那张互补——那张证明「配置在哪」，这张证明「配置之后长什么样」。
  // 内容由 `GenerativeSlotPreview` 手绘（不经过 genui 的异步恢复链路），
  // 形状与真实生成结果同构。
  for (final desktop in [false, true]) {
    final label = desktop ? 'genui-today-desktop' : 'genui-today';
    testWidgets(
      'generate $label',
      (tester) => capture(
        tester,
        generative: true,
        desktop: desktop,
        placement: (folder: 'generative', prefix: ''),
        name: label,
        route: '/',
        longCapture: false,
        scrolledCapture: false,
        record: (name, count) => manifest.writeln(
          '| `$name` | generative | today | `/` | $count | '
          '生成式区块：三张并排小卡'
          '${_frameKindLabel(name)} |',
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
