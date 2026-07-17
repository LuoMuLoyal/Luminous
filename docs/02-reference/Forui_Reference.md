# Forui 参考（项目版）

> 版本：`forui: 0.23.0`，`forui_hooks: 0.23.0`。

## 给 AI 读文档的最佳选择

本地下载的 Forui 文档分为两类：

- `forui-docs/llms-full.txt`
  - 格式: 纯 Markdown，聚合了全部官方文档和代码示例
  - 是否适合喂给 AI: ✅ **首选**
- `forui-docs/llms.txt`
  - 格式: 索引，含每页标题、描述和链接
  - 是否适合喂给 AI: ✅ 快速查范围
- `forui-docs/docs/content/docs/**/*.mdx`
  - 格式: MDX（Markdown + JSX），引用了缺失的 `snippets/*.json`
  - 是否适合喂给 AI: ❌ JSX 噪音大、示例不完整
- Pub/Cache 源码
  - 格式: Dart 源码
  - 是否适合喂给 AI: ✅ 查 API 签名和默认样式时最准确

推荐顺序：
1. 需要了解某个组件怎么用 → 优先看 `llms-full.txt` 里对应章节。
2. 需要确认 API 参数或默认样式 → 看 `Pub/Cache/hosted/pub.dev/forui-0.23.0/lib/src/widgets/...`。
3. 需要项目实际用法 → 看本文件和 `lib/core/widgets` 里的封装。

官方地址：
- 文档站：https://forui.dev/docs
- API 文档：https://pub.dev/documentation/forui
- LLMs 约定说明：https://llmstxt.org/

## 项目级使用约定

- **根主题**：`lib/core/theme/theme.dart` 维护 Luminous 可选的 Forui 内置主题族目录，当前直接映射
   `FThemes.blue / green / neutral / orange / red / rose / slate / violet / yellow / zinc` 的 touch
   light/dark 变体；`lib/app/bootstrap.dart` 根据持久化的 `theme.family` + `theme.mode` 派生 `ThemeData`，
   再用 `FTheme` 包裹整棵树。
- **页面 header**：
  - 子页（有返回按钮的 drill-down 页面）统一用 `lib/core/widgets/layout/page_scaffold.dart` 的 `PageScaffold`。
  - Tab 根页统一用 `lib/core/widgets/common/app_top_bar.dart` 的 `AppTopBar`。
- **返回按钮**：统一 `lib/core/widgets/common/app_back_button.dart` 的 `AppBackButton`。
- **图标**：优先用 Forui 自带的 `FLucideIcons.*`，不再使用 Material `Icons.*`。
- **字体**：
  - 正文/默认：`_token.body(context)`
  - 强调/大标题：`_token.display(context)`
  - Tab 根页大标题：`TypographyToken.level9.display(context).copyWith(fontWeight: FontWeight.w800)`
- **间距**：`Spacing.level1`（4）到 `level12`（128）。
- **圆角**：`RadiusTokens.level0` 到 `level9` 及 `levelFull`。
- **颜色**：
  - Widget 层直接读 `context.theme.colors.*`。
  - 数据/领域层用语义枚举 `SemanticColor`，在 widget 处通过 `semanticColor.palette(context)` 解析。

## 常用组件速查

### FScaffold / FHeader

```dart
// 子页（已封装为 PageScaffold，手写时参考）
FScaffold(
  childPad: false,                       // body 自己管 padding
  header: FHeader.nested(
    title: Text(l10n.pageTitle),
    titleAlignment: Alignment.center,
    prefixes: const [AppBackButton()],
    suffixes: actions,
  ),
  child: SafeArea(
    top: false,
    child: content,
  ),
)
```

- `FHeader(...)`：标题左对齐，用于导航栈根页。
- `FHeader.nested(...)`：标题居中，默认用于非根页。
- `childPad: false` 是项目约定，避免 `FScaffold` 默认 padding 和 `ResponsiveContentFrame` 叠加。

### FButton

```dart
FButton(
  onPress: onTap,
  variant: FButtonVariant.primary, // primary / secondary / destructive / outline / ghost
  size: FButtonSizeVariant.md,     // xs / sm / md / lg
  prefix: const Icon(FLucideIcons.plus),
  child: Text(l10n.addAction),
)

// 仅图标
FButton.icon(
  onPress: onTap,
  variant: FButtonVariant.ghost,
  child: const Icon(FLucideIcons.bell),
)

// 需要深度定制外观时用 .raw
FButton.raw(
  onPress: onTap,
  variant: FButtonVariant.ghost,
  style: .delta(
    decoration: .delta([...]),
    contentStyle: .delta(padding: .value(...)),
  ),
  child: ...,
)
```

### FTile / FTileGroup

```dart
FTileGroup(
  children: [
    FTile(
      title: Text(l10n.itemTitle),
      subtitle: Text(l10n.itemSubtitle),
      prefix: const Icon(FLucideIcons.user),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: onTap,
    ),
  ],
)
```

- 设置页分组标签：用 `TypographyToken.level4.body(context).copyWith(color: colors.mutedForeground,
   fontWeight: FontWeight.w600)`。
- 子页瓷砖统一用外层的 `FTileGroup` 边框，内部 `FTile` 不再重复描边。

### FCard

```dart
FCard.raw(
  style: .delta(
    decoration: .shapeDelta(
      color: colors.card,
      shape: RoundedSuperellipseBorder(
        side: BorderSide(color: colors.border),
        borderRadius: context.theme.style.borderRadius.lg,
      ),
    ),
  ),
  child: Padding(padding: const EdgeInsets.all(Spacing.level4), child: content),
)
```

### FTextField / FTextFormField

```dart
FTextFormField.email(
  controller: emailController,
  autovalidateMode: AutovalidateMode.onUserInteraction,
)

FTextFormField.password(
  controller: passwordController,
)

FTextField(
  controller: controller,
  label: Text(l10n.fieldLabel),
  hint: l10n.fieldHint,
)
```

### 对话框 / Sheet

- 底层：`showFDialog<T>(...)`, `showFSheet<T>(side: FLayout.btt / FLayout.rtl, ...)`。
- 项目封装：`lib/core/widgets/common/app_dialog_shell.dart` 的 `showAppDialog` / `AppDialogShell`，统一处理
   `maxWidth`、padding、滚动、键盘 inset。

### 反馈

- Toast：`AppToast.show(context, message)`（封装 `showFToast`）。
- 加载：`FCircularProgress()`。
- 空/错误状态：`AppStateErrorView`, `AppStateMessageView`（均基于 Forui 颜色和卡片）。

## 样式 Delta 基础

Forui 组件的样式通过 `.delta(...)` 做局部覆盖，而不是自己写全套 `Style`。

```dart
FButton.raw(
  variant: FButtonVariant.ghost,
  style: .delta(
    decoration: .delta([
      .all(
        .shapeDelta(
          color: colors.primary.withValues(alpha: 0.08),
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: colors.border),
            borderRadius: context.theme.style.borderRadius.pill,
          ),
        ),
      ),
    ]),
    contentStyle: const .delta(
      padding: .value(EdgeInsets.symmetric(horizontal: Spacing.level3)),
    ),
  ),
  child: ...,
)
```

需要大量定制时，优先用官方 CLI：

```bash
dart run forui style ls          # 看支持哪些 style
dart run forui style create headers
dart run forui style create dialog
```

## 与 Riverpod / Hooks 的配合

- 带 controller 的 Forui 组件优先用 `forui_hooks` 提供的 hook，避免手写 `initState`/`dispose`。
- 例：`useFSelectController<T>()`, `useFDateController()` 等。
- 项目已全面迁移到 `flutter_hooks` + `hooks_riverpod`。

## 避免的旧习惯

- 不要再新建 `App*` 薄包装去包 Forui 基础组件（如 `AppButton`、`AppCard`）。
- 不要再手写 `Material` / `InkWell` / `Scaffold` / `AppBar`。
- 不要再保留 `AppThemeSurface`、`AppTypographyTokens`、`AppSectionSurface`、`AppColorTokens`、
   `AppShadowTokens`、`AppInkWell`、`AppDialog` 等已删除别名。
