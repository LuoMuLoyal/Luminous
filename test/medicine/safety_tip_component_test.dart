import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/composition/components/registry.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/medicine/domain/entities/safety_tip.dart';
import 'package:luminous/features/medicine/presentation/components/catalog.dart';
import 'package:luminous/features/medicine/presentation/providers/safety/tips.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/safety_tip.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_forui_app.dart';

/// `safety.tip_card` 的渲染契约。
///
/// 卡片只有正文一行块：类别与来源都不该上屏。取不到提示时 `build` 返回 `null`，
/// 宿主连间距一起移除——不留空壳卡片。
void main() {
  const tip = MedicineSafetyTip(
    id: 'tip-1',
    text: '服药期间避免饮酒',
    category: 'alcohol',
  );

  Widget wrap(List<MedicineSafetyTip> tips) {
    return ProviderScope(
      overrides: [
        medicineSafetyTipListProvider.overrideWith(() => _StubTips(tips)),
      ],
      child: TestForuiApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              final component = buildComponentRegistry().find(
                medicineSafetyTipId,
              );
              final card = component?.build(
                context,
                ref,
                const ComponentRenderContext(
                  surface: SurfaceId.medicine,
                  id: medicineSafetyTipId,
                ),
                component.defaultConfig,
              );
              return card ?? const SizedBox.shrink(key: Key('skipped'));
            },
          ),
        ),
      ),
    );
  }

  testWidgets('有提示时渲染正文，类别不上屏', (tester) async {
    await tester.pumpWidget(wrap(const [tip]));
    await tester.pumpAndSettle();

    expect(find.byType(SafetyTipCard), findsOneWidget);
    expect(find.text('服药期间避免饮酒'), findsOneWidget);
    expect(find.text('alcohol'), findsNothing);
    expect(
      find.byKey(const Key('medicine-safety-tip-tip-1')),
      findsOneWidget,
    );
  });

  testWidgets('没有提示时整块跳过，不留空卡', (tester) async {
    await tester.pumpWidget(wrap(const []));
    await tester.pumpAndSettle();

    expect(find.byType(SafetyTipCard), findsNothing);
    expect(find.byKey(const Key('skipped')), findsOneWidget);
  });
}

class _StubTips extends MedicineSafetyTipListNotifier {
  _StubTips(this._tips);

  final List<MedicineSafetyTip> _tips;

  @override
  Future<List<MedicineSafetyTip>> build() async => _tips;
}
