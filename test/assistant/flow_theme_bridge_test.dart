import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/theme/family.dart';
import 'package:luminous/features/assistant/presentation/widgets/flow_theme_bridge.dart';
import 'package:material_ui/material_ui.dart';

/// A lightweight test app that wraps [child] with a Flutter MaterialApp
/// and the Forui theme. This avoids material_ui's MaterialApp so that
/// Flutter's Theme.of(context) works correctly with flow_theme_bridge.
class _TestFlowApp extends StatelessWidget {
  const _TestFlowApp({this.themeMode = flutter.ThemeMode.light, this.home});

  final flutter.ThemeMode themeMode;
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == flutter.ThemeMode.dark;
    // The framework's MaterialApp installs a Flutter-framework Theme; the
    // Material-based `Theme`/`ThemeData` this test drives are material_ui's
    // (see the bridge's doc comment), so the two are aliased apart here.
    return flutter.MaterialApp(
      theme: flutter.ThemeData.light(),
      darkTheme: flutter.ThemeData.dark(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => FTheme(
        data: isDark
            ? appThemeData(appDefaultThemeFamily, Brightness.dark)
            : appThemeData(appDefaultThemeFamily, Brightness.light),
        child: child ?? const SizedBox.shrink(),
      ),
      home: home,
    );
  }
}

void main() {
  testWidgets(
    'assistant FlowTheme is scoped and preserves parent theme extensions',
    (tester) async {
      await tester.pumpWidget(
        _TestFlowApp(
          home: Theme(
            data: ThemeData(
              brightness: Brightness.light,
              extensions: const <ThemeExtension<dynamic>>[
                _ParentThemeExtension(),
              ],
            ),
            child: Builder(
              builder: (context) => Column(
                children: [
                  const _ThemeProbe(label: 'outside'),
                  withLuminousFlowTheme(
                    context,
                    const _ThemeProbe(label: 'inside'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('outside: no-flow, parent'), findsOneWidget);
      expect(find.text('inside: flow, parent'), findsOneWidget);
    },
  );

  testWidgets('uses the dark FlowUI preset for a dark ambient theme', (
    tester,
  ) async {
    // 刻意**不**再包一层 Flutter 框架 `ThemeData(brightness: dark)`：
    // 旧用例靠那层才能让 `Theme.of(context).brightness` 报 dark，而这层在
    // 生产路径里不存在（根是 material_ui 的 MaterialApp，框架 Theme.of
    // 取到的是另一个 Theme），于是 dark 分支在生产不可达——测试反而把
    // 缺陷掩盖了。现在 bridge 改读 Forui 的 brightness，这里只给 Forui
    // 主题，与生产一致。
    await tester.pumpWidget(
      _TestFlowApp(
        themeMode: flutter.ThemeMode.dark,
        home: Builder(
          builder: (context) {
            final flowTheme = luminousFlowTheme(context);
            return Text(
              '${context.theme.colors.brightness.name}|'
              '${flowTheme.colors.tertiary == FlowColors.dark.tertiary ? 'dark' : 'light'}',
              key: const Key('flow-dark-probe'),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('flow-dark-probe'))).data,
      'dark|dark',
    );
  });

  testWidgets('uses the light FlowUI preset for a light ambient theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestFlowApp(
        home: Builder(
          builder: (context) {
            final flowTheme = luminousFlowTheme(context);
            return Text(
              '${context.theme.colors.brightness.name}|'
              '${flowTheme.colors.primaryContainer == FlowColors.light.primaryContainer ? 'light' : 'dark'}',
              key: const Key('flow-light-probe'),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('flow-light-probe'))).data,
      'light|light',
    );
  });

  testWidgets('FlowUI preset follows the Forui theme, not the framework Theme', (
    tester,
  ) async {
    // 回归守卫：制造「框架 Theme 报 light、Forui 主题是 dark」的矛盾组合。
    // 若 bridge 改回读 `Theme.of(context).brightness`，这里会拿到 light 预设而失败。
    // 这正是生产的真实形状——根是 material_ui 的 MaterialApp，框架 Theme.of
    // 取到的是另一个 Theme，brightness 恒为 light（一次性探针实测）。
    await tester.pumpWidget(
      _TestFlowApp(
        themeMode: flutter.ThemeMode.dark,
        home: Builder(
          builder: (context) {
            // 在 Forui dark 之上再套一层**框架** light Theme：框架 `Theme.of`
            // 因此报 light，而 Forui 的 brightness 仍为 dark。
            return flutter.Theme(
              data: flutter.ThemeData.light(),
              child: Builder(
                builder: (context) {
                  final frameworkBrightness = flutter.Theme.of(
                    context,
                  ).brightness;
                  final foruiBrightness = context.theme.colors.brightness;
                  final flowTheme = luminousFlowTheme(context);
                  return Text(
                    '${frameworkBrightness.name}|${foruiBrightness.name}|'
                    '${flowTheme.colors.tertiary == FlowColors.dark.tertiary ? 'dark' : 'light'}',
                    key: const Key('flow-brightness-source-probe'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const Key('flow-brightness-source-probe')))
          .data,
      'light|dark|dark',
    );
  });

  testWidgets('uses the ambient Forui font family and package', (tester) async {
    final baseTheme = appThemeData(appDefaultThemeFamily, Brightness.light);
    final ambientTypeface = FTypeface.inherit(
      colors: baseTheme.colors,
      touch: true,
      fontFamily: 'packages/ambient_package/AmbientFamily',
    );

    await tester.pumpWidget(
      _TestFlowApp(
        home: FTheme(
          data: FThemeData(
            colors: baseTheme.colors,
            typography: FTypography(
              display: ambientTypeface,
              body: ambientTypeface,
            ),
            style: baseTheme.style,
            touch: true,
          ),
          child: Builder(
            builder: (context) {
              final style = luminousFlowTheme(context).typography.bodyLarge;
              return Text(style.fontFamily ?? 'missing-font-family');
            },
          ),
        ),
      ),
    );

    expect(find.text('packages/ambient_package/AmbientFamily'), findsOneWidget);
  });

  testWidgets('replaces a parent FlowTheme without duplicating it', (
    tester,
  ) async {
    const sentinelSurface = Color(0xFF010203);
    const sentinelPrimary = Color(0xFF030405);
    final parentFlowTheme = FlowTheme(
      colors: FlowColors.light.copyWith(
        surface: sentinelSurface,
        primary: sentinelPrimary,
      ),
    );

    await tester.pumpWidget(
      _TestFlowApp(
        home: Theme(
          data: ThemeData(extensions: [parentFlowTheme]),
          child: Builder(
            builder: (context) => withLuminousFlowTheme(
              context,
              const SizedBox(key: Key('flow-theme-replacement-child')),
            ),
          ),
        ),
      ),
    );

    final childContext = tester.element(
      find.byKey(const Key('flow-theme-replacement-child')),
    );
    final childFlowThemes = Theme.of(
      childContext,
    ).extensions.values.whereType<FlowTheme>().toList();
    final expectedFlowTheme = luminousFlowTheme(childContext);

    expect(childFlowThemes, hasLength(1));
    expect(
      childFlowThemes.single.colors.surface,
      expectedFlowTheme.colors.surface,
    );
    expect(
      childFlowThemes.single.colors.primary,
      expectedFlowTheme.colors.primary,
    );
    expect(childFlowThemes.single.colors.surface, isNot(sentinelSurface));
    expect(childFlowThemes.single.colors.primary, isNot(sentinelPrimary));
  });
}

class _ThemeProbe extends StatelessWidget {
  const _ThemeProbe({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFlowTheme = theme.extension<FlowTheme>() != null;
    final hasParentExtension = theme.extension<_ParentThemeExtension>() != null;
    return Text(
      '$label: ${hasFlowTheme ? 'flow' : 'no-flow'}, '
      '${hasParentExtension ? 'parent' : 'no-parent'}',
    );
  }
}

/// Stands in for any non-FlowUI extension a host may have installed; it lives
/// on `material_ui`'s [ThemeExtension] because that is the channel
/// [withLuminousFlowTheme] writes to.
class _ParentThemeExtension extends ThemeExtension<_ParentThemeExtension> {
  const _ParentThemeExtension();

  @override
  _ParentThemeExtension copyWith() => this;

  @override
  _ParentThemeExtension lerp(
    covariant ThemeExtension<_ParentThemeExtension>? other,
    double t,
  ) => this;
}
