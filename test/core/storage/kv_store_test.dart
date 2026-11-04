import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// [HiveKvStore.open] 的存储位置契约。
///
/// 关键不变量：偏好库落在**应用私有**的 application support 目录，而不是用户
/// 共享的 documents 目录。Linux/Windows 上 documents 是 `$HOME/Documents` 这种
/// 按用户的公共文件夹，两份安装会打开同一个 box，Hive 的 `flock` 让后启动的那份
/// 在 `runApp` 之前以 `errno 11` 退出（Ubuntu 26 实测，2026-11-03）。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingPathProvider pathProvider;
  late Directory tempRoot;
  late Directory documentsRoot;

  setUp(() {
    // 真实临时目录：Hive 要在这里落盘，用假路径会在 openBox 里再炸一次。
    tempRoot = Directory.systemTemp.createTempSync('luminous-kv-store-test-');
    documentsRoot = Directory(
      '${tempRoot.path}${Platform.pathSeparator}documents',
    )..createSync(recursive: true);
    pathProvider = _RecordingPathProvider(
      supportRoot: tempRoot.path,
      documentsRoot: documentsRoot.path,
    );
    PathProviderPlatform.instance = pathProvider;
  });

  tearDown(() async {
    // 先关 Hive：box 的 lock 文件在打开期间被持有，Windows 上不关就删不掉目录。
    await Hive.close();
    KvStore.clearForTesting();
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });

  test('opens the box under the application support directory', () async {
    final store = await HiveKvStore.open();

    expect(
      pathProvider.requested,
      contains('support'),
      reason: 'KV box 必须从 application support 取存储根',
    );
    expect(
      pathProvider.requested,
      isNot(contains('documents')),
      reason: 'documents 是用户共享目录，两份安装会撞同一把锁',
    );
    expect(store, same(KvStore.instance));
  });

  test('creates the box directory under the support root', () async {
    await HiveKvStore.open();

    final boxDir = Directory('${tempRoot.path}${Platform.pathSeparator}kv');
    expect(boxDir.existsSync(), isTrue);
    expect(documentsRoot.listSync(), isEmpty, reason: '偏好库不得写进 documents 根');
  });
}

/// Records which `path_provider` entry points the store uses.
class _RecordingPathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _RecordingPathProvider({
    required this.supportRoot,
    required this.documentsRoot,
  });

  final String supportRoot;
  final String documentsRoot;

  final List<String> requested = <String>[];

  @override
  Future<String?> getApplicationSupportPath() async {
    requested.add('support');
    return supportRoot;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    requested.add('documents');
    return documentsRoot;
  }
}
