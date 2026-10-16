import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/settings/presentation/pages/oss_licenses.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/oss_licenses.dart';

import '../helpers/test_forui_app.dart';

void main() {
  const l10n = AppLocalizations.delegate;

  test('generated manifest covers the dependencies added in this plan', () {
    // 清单由 pubspec.lock 生成。这几个包是本计划新引入的，若生成器漏了它们
    // （例如被 `-i` 误伤），这里会先炸，而不是等用户点进详情页看到空白。
    for (final name in [
      'app_links',
      'webview_flutter',
      'photo_view',
      'add_2_calendar',
      'dart_pubspec_licenses',
    ]) {
      final match = allDependencies.where((p) => p.name == name);
      expect(match, isNotEmpty, reason: '$name 不在生成的许可清单里');
      expect(match.first.version, isNotNull, reason: '$name 缺版本号');
    }
  });

  test('every pub-hosted entry carries a non-empty license text', () {
    // `isSdk` 为 true 的是 SDK 包（flutter_driver 等）与 path 依赖
    // （lucent_api 等）：它们不在 pub cache 里，生成器读不到 LICENSE，
    // 因此没有许可文本。这里只对 pub 托管包断言；SDK 自身的许可由内置
    // showLicensePage 覆盖，两页互补。
    final hosted = allDependencies.where((p) => !p.isSdk);
    expect(hosted, isNotEmpty);
    for (final package in hosted) {
      expect(package.name, isNotEmpty);
      expect(
        package.license?.trim(),
        isNotEmpty,
        reason: '${package.name} 没有许可文本',
      );
    }
  });

  testWidgets('list page renders one tile per dependency', (tester) async {
    await tester.pumpWidget(const TestForuiApp(home: OssLicensesPage()));
    await tester.pumpAndSettle();

    // 按名字排序，add_2_calendar 在首屏；photo_view 在很下面，需要滚动。
    expect(find.text('add_2_calendar'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('photo_view'), 300);
    expect(find.text('photo_view'), findsOneWidget);
  });

  testWidgets('detail page shows version and license body', (tester) async {
    final zh = await l10n.load(const Locale('zh'));
    final package = allDependencies.firstWhere((p) => p.name == 'photo_view');

    await tester.pumpWidget(
      const TestForuiApp(home: OssLicenseDetailPage(name: 'photo_view')),
    );
    await tester.pumpAndSettle();

    expect(find.text(package.version!), findsOneWidget);
    expect(find.text(zh.settingsAboutLicenseVersionLabel), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
  });

  testWidgets('detail page copies license text to the clipboard', (
    tester,
  ) async {
    final zh = await l10n.load(const Locale('zh'));
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      const TestForuiApp(
        home: OssLicenseDetailPage(name: 'photo_view'),
        // Toast 需要一个 FToaster，否则复制后的反馈会抛。
        showToaster: true,
      ),
    );
    await tester.pumpAndSettle();

    // 不能按 FButton 类型找：PageScaffold 的返回键也是 FButton（FButton.icon）。
    await tester.tap(find.widgetWithText(FButton, zh.commonCopy));
    await tester.pumpAndSettle();

    expect(copied, hasLength(1));
    expect(copied.single, contains('MIT'));

    // 排掉 Toast 的 1800ms 计时器，否则测试结束时仍在 pending。
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('detail page falls back when the name is unknown', (
    tester,
  ) async {
    final zh = await l10n.load(const Locale('zh'));

    await tester.pumpWidget(
      const TestForuiApp(home: OssLicenseDetailPage(name: 'no_such_pkg')),
    );
    await tester.pumpAndSettle();

    // 未知包名不该崩，也不该把复制按钮留在可点状态。
    expect(find.text('no_such_pkg'), findsOneWidget);
    expect(find.text(zh.settingsAboutLicenseMissing), findsOneWidget);
    final copyButton = tester.widget<FButton>(
      find.widgetWithText(FButton, zh.commonCopy),
    );
    expect(copyButton.onPress, isNull);
  });
}
