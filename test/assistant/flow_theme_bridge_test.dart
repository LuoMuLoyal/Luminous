import 'package:flow_ui/flow_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/features/assistant/presentation/widgets/flow_theme_bridge.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets(
    'assistant FlowTheme is scoped and preserves parent theme extensions',
    (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
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
    await tester.pumpWidget(
      TestForuiApp(
        themeMode: ThemeMode.dark,
        home: Theme(
          data: ThemeData(brightness: Brightness.dark),
          child: Builder(
            builder: (context) {
              final flowTheme = luminousFlowTheme(context);
              return Text(
                '${Theme.of(context).brightness.name}|'
                '${flowTheme.colors.primaryContainer == FlowColors.dark.primaryContainer ? 'dark' : 'light'}',
                key: const Key('flow-dark-probe'),
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('flow-dark-probe'))).data,
      'dark|dark',
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
      TestForuiApp(
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
      TestForuiApp(
        home: Theme(
          data: ThemeData(
            // FlowTheme extends flutter/material.dart's ThemeExtension,
            // which is incompatible with material_ui's ThemeExtension at
            // the type-system level, but compatible at runtime.
            extensions: [parentFlowTheme] as Iterable<ThemeExtension<dynamic>>,
          ),
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
