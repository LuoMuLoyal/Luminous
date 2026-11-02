import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/composition/components/registry.dart';
import 'package:luminous/shared/domain/composition/size.dart';

/// 默认布局索求的尺寸，必须被对应组件支持。
///
/// ## 为什么这是一条回归测试而不是「防御性代码」
///
/// `_spanOf`（`core/composition/host.dart`）在尺寸不被支持时会**回退到组件
/// 支持的最小尺寸**，而不是报错或忽略。这个降级本身是对的——旧版本存下的
/// 布局不能因为组件改了尺寸集合就炸掉整个页面。但它的代价是：
///
/// 一个组件在 `supportedSizes` 里漏写 `compact`，默认布局又要 `compact`，
/// 于是它静默取 `regular`；而 `regular` 在双列桌面网格里跨满两列。
/// 界面上看不出任何报错，只看到「这张卡为什么占满整行」。
///
/// 2026-11 的 today 页就是这样：`suggestion.primary`、`summary.metrics`、
/// `health_event.active` 三个组件都缺 `compact`，桌面上三张卡全部满宽，
/// 默认布局里写的 `compact` 形同虚设。这条测试拦的是同一类错误。
void main() {
  final registry = buildComponentRegistry();
  final catalog = buildSurfaceCatalog();

  test('registry knows every default placement', () {
    for (final definition in catalog.definitions) {
      for (final placement in definition.defaultLayout.placements) {
        expect(
          registry.find(placement.id),
          isNotNull,
          reason:
              '${definition.surface.wireValue} 的默认布局引用了未注册组件 '
              '${placement.id.value}',
        );
      }
    }
  });

  test('every default placement asks for a size its component supports', () {
    for (final definition in catalog.definitions) {
      for (final placement in definition.defaultLayout.placements) {
        final component = registry.find(placement.id);
        if (component == null) continue; // 上一条测试已经报过
        expect(
          component.supportedSizes,
          contains(placement.size),
          reason:
              '${definition.surface.wireValue} 的 ${placement.id.value} 索求 '
              '`${placement.size.name}`，但组件只支持 '
              '`${component.supportedSizes.map((s) => s.name).join(' / ')}`。\n'
              '不匹配会回退到最小尺寸——在双列桌面网格里，这会让卡片跨满整行。',
        );
      }
    }
  });

  test('no default placement spans the full row on desktop', () {
    // 桌面双列的产品规则：**所有卡片等宽**，不出现独占整列的组件。
    //
    // 这条约束的由来：`ComponentPlacement` 省略 `size` 时默认是 `regular`，
    // 而 `regular` 在双列下 span = columns = 2 —— 一个忘记写 `size:` 的放置
    // 会静默变成整行。`wide` 同理。两者都不会报错，只有肉眼看截图才发现
    // 「这张卡怎么占了两列」，所以在这里按声明层面拦死。
    for (final definition in catalog.definitions) {
      for (final placement in definition.defaultLayout.placements) {
        expect(
          placement.size,
          ComponentSize.compact,
          reason:
              '${definition.surface.wireValue} 的 ${placement.id.value} 是 '
              '`${placement.size.name}`。桌面双列要求所有组件都是 `compact`'
              '（占半列）；`regular` / `wide` 会跨满整行。',
        );
      }
    }
  });
}
