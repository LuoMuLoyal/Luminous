import 'package:genui/genui.dart';

/// 生成式 UI 可用的组件白名单。
///
/// A2UI 的组件树只能落在注册过的 [CatalogItem] 上；未知 type 由 `genui` 的
/// fallback 渲染。这里是**第一道闸**：连注册都不给的 type，agent 根本选不到。
///
/// 分两层：
/// - **展示原语**：`Text` / `Column` / `Row` / `Card` / `List` / `Divider` /
///   `Icon` / `Image`。agent 用它们拼布局。
/// - **领域 item**：组合根注入（`lib/app/composition/generative/`），只接受
///   引用键，渲染时从 Riverpod 取真值。
///
/// **刻意不包含**（每一条都是能力上的减法，不是偏好）：
/// - `Button` —— 去掉一切可写动作；
/// - `TextField` / `Slider` / `CheckBox` / `DateTimeInput` —— 用户输入走既有表单；
/// - `Modal` / `Tabs` —— 导航归 GoRouter；
/// - `AudioPlayer` / `Video` —— 医疗场景无正当用途，且带音视频权限声明。
final class GenerativeCatalog {
  GenerativeCatalog({required this.domainItems, this.catalogId});

  /// 领域 item，由组合根提供。
  final List<CatalogItem> domainItems;

  /// catalog 标识，写进 `createSurface.catalogId`。
  final String? catalogId;

  /// 白名单内的展示原语。
  ///
  /// 逐项列举而不是按名字过滤 `BasicCatalogItems.asCatalog()`：后者把
  /// `Button` / `TextField` 等一起塞进来，过滤一轮等于给了它们一个"曾经注册
  /// 过"的假象，不如在源头就不出现。
  static List<CatalogItem> get primitives => [
    BasicCatalogItems.text,
    BasicCatalogItems.column,
    BasicCatalogItems.row,
    BasicCatalogItems.card,
    BasicCatalogItems.list,
    BasicCatalogItems.divider,
    BasicCatalogItems.icon,
    BasicCatalogItems.image,
  ];

  /// 组装成 `genui` 的 [Catalog]。
  ///
  /// 不使用 `BasicCatalogItems.asCatalog()`：它的 `systemPromptFragments` 用
  /// `basicCatalogRules` 描述全部基础组件（含 `Button` 的 `action` 规则），
  /// 会让提示词教模型使用我们没注册的组件。
  Catalog toCatalog() {
    return Catalog(
      [...primitives, ...domainItems],
      catalogId: catalogId,
      systemPromptFragments: [BasicCatalogItems.basicCatalogRules],
    );
  }

  /// 已注册的 type 名，供提示词摘要与调试使用。
  Set<String> get typeNames => {
    ...primitives.map((item) => item.name),
    ...domainItems.map((item) => item.name),
  };
}
