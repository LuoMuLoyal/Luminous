import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:a2ui_flutter/basic_catalog.dart';

/// 生成式 UI 能渲染的全部组件。
///
/// A2UI 1.0 取消了「受限词汇表」：`basicCatalog()` 的**全部**组件都注册
/// （Button / TextField / CheckBox / ChoicePicker / Slider / DateTimeInput /
/// Tabs / Modal / Video / AudioPlayer），agent 可以拼任何界面、下发任何动作。
///
/// 分两半：
/// - **基础组件**：`basicCatalog()`，由包的实现提供；
/// - **领域组件**：组合根注入（`lib/app/composition/generative/`），它们从
///   本仓的 Riverpod 取真实业务数据，不是因为「安全」才只收引用键，而是因为
///   这些数据本来就在客户端。
///
/// 两半合成**一个** catalog，id 用 [luminousCatalogId]：v1.0 支持每个组件带
/// 自己的 `@catalogId` 混用，但让服务端只面对一个 id 更省事——提示词里的词汇
/// 表、`createSurface.catalogId`、错误信息都只有一个值。
final class GenerativeCatalog {
  GenerativeCatalog({
    required this.domainComponents,
    this.locale = 'en-US',
    this.openUrl,
  });

  /// 本仓自定义组件（由组合根提供）。
  final List<ComponentImplementation> domainComponents;

  /// basic catalog 的语言：决定数字、日期与 `formatString` 的格式。
  ///
  /// 必须传界面当前语言，不能吃默认的 `en-US`——否则中文界面里 agent 拼出来的
  /// 日期和金额是英文格式。
  final String locale;

  /// `openUrl` 回调。不传时 agent 的 `openUrl` 调用直接失败。
  final OpenUrlCallback? openUrl;

  /// 本仓 catalog 的 id，写进 `createSurface.catalogId` 与能力声明。
  static const String luminousCatalogId =
      'https://luminous.app/a2ui/catalog/v1.json';

  /// 装配好的 catalog（惰性，构造一次）。
  late final CatalogImplementation _catalog = _build();

  CatalogImplementation get catalog => _catalog;

  CatalogImplementation _build() {
    final basic = basicCatalog(locale: locale, openUrl: openUrl);
    if (domainComponents.isEmpty) {
      // 没有领域组件时仍然换成自己的 id：surface 的 catalogId 不该随「有没有
      // 自定义组件」变化，否则同一条消息在两种装配下校验结果不同。
      return basic.derive(
        catalogId: luminousCatalogId,
        instructions: basic.instructions,
      );
    }
    return basic.derive(
      catalogId: luminousCatalogId,
      addComponents: domainComponents,
      // `derive` 不继承 instructions，而那是教模型怎么写消息的主要材料，
      // 必须显式带过去。
      instructions: basic.instructions,
    );
  }

  /// 已注册的组件 type 名，调试 / 日志用。
  Set<String> get typeNames => catalog.components.keys.toSet();

  /// 给服务端提示词用的 catalog 文档。
  ///
  /// 服务端不再手抄词汇表（旧版 `surface-policy.ts` 那份），提示词直接由这份
  /// 文档生成——两仓之间只有一份事实。
  Map<String, Object?> toDocument() => catalog.toJson();
}
