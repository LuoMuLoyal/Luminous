import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/theme/family.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 登录提示弹窗按 Apple HIG 的 alert 规格渲染。
///
/// HIG 对 alert 的约束（Human Interface Guidelines → Alerts）：
/// - 宽度固定 270pt，居中，**不随屏幕变大**；
/// - 标题与正文居中、等宽；
/// - 两个按钮并排、等宽，取消在左。
///
/// 回归点：该弹窗曾用自适应宽度，在浏览器窗口里被拉成一条横亘整屏的长条，
/// 按钮挤在左边，完全不像 alert。
void main() {
  Future<void> pumpAndOpen(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FTheme(
          data: appThemeData(AppThemeFamily.neutral, Brightness.light),
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      showAuthRequiredDialog(context, onLogin: () {}),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('alert keeps a constant width regardless of screen size', (
    tester,
  ) async {
    final widths = <double>[];
    for (final w in [393.0, 700.0, 1400.0]) {
      await pumpAndOpen(tester, Size(w, 900));
      widths.add(
        tester.getSize(find.byKey(const Key('auth-required-dialog'))).width,
      );
    }

    // HIG: fixed width. Every screen size yields the same alert width.
    expect(widths.toSet(), hasLength(1));
    // 270pt alert minus 2×16pt content padding = 238 content width.
    expect(widths.first, closeTo(238, 1));
  });

  testWidgets('the two actions sit side by side with equal width', (
    tester,
  ) async {
    await pumpAndOpen(tester, const Size(700, 900));

    final cancel = find.byKey(const Key('auth-required-cancel-action'));
    final login = find.byKey(const Key('auth-required-login-action'));

    expect(tester.getTopLeft(cancel).dy, tester.getTopLeft(login).dy);
    expect(
      tester.getSize(cancel).width,
      closeTo(tester.getSize(login).width, 0.5),
    );
    // Cancel is on the left.
    expect(tester.getTopLeft(cancel).dx, lessThan(tester.getTopLeft(login).dx));
  });
}
