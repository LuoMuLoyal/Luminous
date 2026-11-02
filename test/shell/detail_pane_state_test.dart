import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/shell/presentation/detail_pane_state.dart';

/// 详情面板的开关状态。
///
/// 面板本身是纯 UI（`FResizable` + 内容渲染），可测性在于**状态语义**：
/// 什么时候算「同一个目标」、关闭是否幂等、toggle 是否真的来回切换。
/// 这些错了，表现是「点第二次没反应」或「点别的药面板内容不换」——
/// 都是肉眼难查、但用户一用就撞上的问题。
void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  DetailPaneController controller() =>
      container.read(detailPaneProvider.notifier);

  DetailPaneTarget? state() => container.read(detailPaneProvider);

  test('starts closed', () {
    expect(state(), isNull);
  });

  test('open sets the target', () {
    controller().open(const MedicineDetailTarget(source: 'cn', id: 'a'));
    expect(state(), const MedicineDetailTarget(source: 'cn', id: 'a'));
  });

  test('close returns to null', () {
    controller().open(const MedicineDetailTarget(source: 'cn', id: 'a'));
    controller().close();
    expect(state(), isNull);
  });

  test('opening the same target twice does not notify again', () {
    const target = MedicineDetailTarget(source: 'cn', id: 'a');
    controller().open(target);
    final first = state();

    controller().open(target);
    // 同一个目标重复 open 是幂等的：状态对象没变，避免无谓重建。
    expect(state(), same(first));
  });

  test('opening a different target switches content', () {
    controller().open(const MedicineDetailTarget(source: 'cn', id: 'a'));
    controller().open(const MedicineDetailTarget(source: 'cn', id: 'b'));
    expect(state(), const MedicineDetailTarget(source: 'cn', id: 'b'));
  });

  test('same id but different source counts as a different target', () {
    // `cn` 与 `drugbank` 是两套完全不同的说明书数据，不能当成同一个。
    controller().open(const MedicineDetailTarget(source: 'cn', id: 'x'));
    controller().open(const MedicineDetailTarget(source: 'drugbank', id: 'x'));
    expect(state(), const MedicineDetailTarget(source: 'drugbank', id: 'x'));
  });

  test('toggle opens then closes the same target', () {
    const target = MedicineDetailTarget(source: 'drugbank', id: 'DB00176');
    controller().toggle(target);
    expect(state(), target);

    controller().toggle(target);
    expect(state(), isNull);
  });

  test('toggle switches to a different target instead of closing', () {
    const a = MedicineDetailTarget(source: 'cn', id: 'a');
    const b = MedicineDetailTarget(source: 'cn', id: 'b');
    controller().toggle(a);
    controller().toggle(b);
    expect(state(), b);
  });

  test('equality is value-based, not identity-based', () {
    // 面板每次重建都会构造新的 target 对象，值相等必须意味着「同一个目标」，
    // 否则上面的幂等与 toggle 判断全部失效。
    //
    // 两个不同来源的同 id 目标必须**不**相等：`cn` 与 `drugbank` 是两套
    // 不同的说明书数据，混为一谈会让面板显示错药。
    const a = MedicineDetailTarget(source: 'cn', id: 'a');
    const b = MedicineDetailTarget(source: 'drugbank', id: 'a');
    const sameAsA = MedicineDetailTarget(source: 'cn', id: 'a');

    expect(a, isNot(b));
    expect(a, sameAsA);
    expect(a.hashCode, sameAsA.hashCode);
  });
}
