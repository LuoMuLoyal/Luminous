import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:a2ui_flutter/basic_catalog.dart';
import 'package:luminous/core/network/config/env_keys.dart';
import 'package:luminous/core/network/config/env_reader.dart';

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
/// 两半合成**一个** catalog，id 用 [catalogId]：v1.0 支持每个组件带
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
  ///
  /// 来源是编译期 `--dart-define=A2UI_CATALOG_ID=...`，与 Lucent 的服务端变量
  /// **同名**：两边必须一致，否则 agent 写进 `createSurface` 的 catalogId 与渲染端
  /// 注册的 catalog 对不上，整批组件会被按 schema 不符拒绝。
  ///
  /// 未配置时用 [defaultCatalogId]。它是对外发布的标识符（出现在每一条
  /// `createSurface` 里），所以默认值刻意用 **URN** 而不是 URL——不替部署方声称
  /// 任何域名。要对外发布就在构建时用 `--dart-define` 指定自己的。
  ///
  /// 空值在这里兜底，而不是把 `fallback:` 交给 `EnvReader`：那条路径只在
  /// `String.fromEnvironment` 分支上套兜底，测试覆盖（`setTestValue`）分支原样
  /// 返回。catalog id 为空会让 surface 建不出来，这个不变量放在使用点更安全。
  static String get catalogId {
    final configured = EnvReader.string(EnvKey.a2uiCatalogId);
    return configured.isEmpty ? defaultCatalogId : configured;
  }

  /// 未配置 `A2UI_CATALOG_ID` 时使用的 catalog id。
  ///
  /// A2UI 规范只要求它是字符串标识（约定写成 URI 以免跨组织撞名），不要求能解析；
  /// `urn:` 形式满足这一条且不声称域名所有权。
  static const String defaultCatalogId = 'urn:a2ui:catalog:luminous:v1';

  /// 装配好的 catalog（惰性，构造一次）。
  late final CatalogImplementation _catalog = _build();

  CatalogImplementation get catalog => _catalog;

  CatalogImplementation _build() {
    final basic = basicCatalog(locale: locale, openUrl: openUrl);
    if (domainComponents.isEmpty) {
      // 没有领域组件时仍然换成自己的 id：surface 的 catalogId 不该随「有没有
      // 自定义组件」变化，否则同一条消息在两种装配下校验结果不同。
      return basic.derive(
        catalogId: catalogId,
        instructions: basic.instructions,
      );
    }
    return basic.derive(
      catalogId: catalogId,
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
