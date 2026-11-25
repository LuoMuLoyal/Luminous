// a2ui_flutter 的 basic catalog 组件建在 **framework material** 上
// （包内 `Card` / `TextField` / `Slider` 都 import `package:flutter/material.dart`），
// 而本仓界面已迁到 `material_ui`。这里显式用 framework 类型拼 `ThemeData`，
// 属预期内豁免。
// ignore_for_file: deprecated_member_use
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:a2ui_flutter/basic_catalog.dart';
import 'package:flutter/material.dart' as fw;
// 未加前缀的那一半：Widget / Key / MediaQuery 等平台无关类型，避免每次写
// `fw.Widget`；material 专有的名字仍走 `fw.`，不会被 `material_ui` 撞名。
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/composition/a2ui/transport.dart';
import 'package:luminous/core/design/design.dart';
// 亮度取自本应用的 MaterialApp（`material_ui`）。**不能**用 framework 的
// `Theme.of(context).brightness`：应用外壳是 `material_ui` 的 `MaterialApp`，
// 树里没有 framework `Theme` 祖先，那会直接断言失败。
import 'package:material_ui/material_ui.dart' as mui;

/// 渲染一个已生成的 surface。
///
/// 四层包装，每层各解决一件事：
/// 1. [_A2uiMaterialTheme]：把 Forui 主题翻译成 **framework** `ThemeData`
///    （basic catalog 的组件读的是 framework 的 `Theme.of`）；
/// 2. [A2uiMarkdown]：`Text` 的 body 走本仓的 markdown 样式；
/// 3. [A2uiSurface]：包内的根节点；
/// 4. [LimitedBox]：agent 的树可能给 `TextField` 无界宽度，收紧到屏幕宽。
///
/// 入参是 [transport] + [surfaceId] 而不是渲染模型本身：`SurfaceModel` 是
/// `a2ui_core` 的类型，feature 的 `presentation/` 不该 import 它（否则 0.x 的
/// API 变更会漏出这个目录）。查表在这里做。
///
/// 调用方只负责「有没有生成结果」这一个判断——三态语义在 `GenerativeSurface`
/// 里，这里不重复。
class GenerativeSurfaceRenderer extends StatelessWidget {
  const GenerativeSurfaceRenderer({
    super.key,
    required this.transport,
    required this.surfaceId,
  });

  final GenerativeTransport transport;

  /// A2UI surface id，`generative.<surface>`。
  final String surfaceId;

  @override
  Widget build(BuildContext context) {
    final model = transport.surfaceFor(surfaceId);
    if (model == null) return const SizedBox.shrink();

    return _GenerativeErrorBoundary(
      child: _A2uiMaterialTheme(
        child: A2uiMarkdown(
          builder: (context, markdown, style) => MarkdownBody(
            data: markdown,
            styleSheet: MarkdownStyle.ai(context),
          ),
          child: LimitedBox(
            // 竖排容器里 agent 可能给一个没有宽度的 `TextField`；没有这层
            // 限制，它会直接报 unbounded width。
            maxWidth: MediaQuery.maybeSizeOf(context)?.width ?? 400,
            child: A2uiSurface(key: ObjectKey(model), surface: model),
          ),
        ),
      ),
    );
  }
}

/// 把生成式内容套进一套 **framework** Material 主题。
///
/// ## 为什么必须自己造一套
///
/// `basicCatalog()` 的组件（`Card` / `Text` / `TextField` / `Slider` …）是
/// framework Material 组件，读 `Theme.of(context).colorScheme` 与
/// `textTheme`。本应用的界面主题是 Forui，`MaterialApp.theme` 走的是
/// `foruiMaterialTheme()`——它返回 `material_ui` 的 `ThemeData`，与 framework
/// 的类型不通用。不套这一层，生成出来的卡片是 M3 的淡紫色，输入框是 M3 的
/// 默认填充，和周围的 Forui 组件一眼就不是一套。
///
/// 映射而不是另起一套设计：卡片取 `colors.card`、正文取 `colors.foreground`、
/// 分割线取 `colors.border`、主色取 `colors.primary`——生成的内容看起来必须是
/// 同一个产品里的东西。
class _A2uiMaterialTheme extends StatelessWidget {
  const _A2uiMaterialTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final forui = context.theme;
    final colors = forui.colors;
    final typography = forui.typography;
    final brightness = mui.Theme.of(context).brightness;

    final scheme = fw.ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.primaryForeground,
      primaryContainer: colors.primary.withValues(alpha: 0.12),
      onPrimaryContainer: colors.foreground,
      secondary: colors.secondary,
      onSecondary: colors.secondaryForeground,
      error: SemanticColor.destructive.solid(context),
      onError: SemanticColor.destructive.foreground(context),
      surface: colors.card,
      onSurface: colors.foreground,
      outline: colors.border,
      outlineVariant: colors.border,
    );

    // Forui 的字阶是紧凑基线（见 `core/theme/family.dart` 的说明），这里逐档
    // 映射而不是用 Material 默认的 textTheme——那会把生成内容放大一档。
    final textTheme = fw.TextTheme(
      headlineLarge: typography.body.xl.copyWith(
        fontWeight: fw.FontWeight.w700,
      ),
      headlineMedium: typography.body.lg.copyWith(
        fontWeight: fw.FontWeight.w700,
      ),
      headlineSmall: typography.body.md.copyWith(
        fontWeight: fw.FontWeight.w700,
      ),
      titleLarge: typography.body.md.copyWith(fontWeight: fw.FontWeight.w600),
      titleMedium: typography.body.sm.copyWith(fontWeight: fw.FontWeight.w600),
      bodyLarge: typography.body.md,
      bodyMedium: typography.body.sm,
      bodySmall: typography.body.xs,
      labelLarge: typography.body.sm,
      labelMedium: typography.body.xs,
      labelSmall: typography.body.xs2,
    );

    return fw.Theme(
      data: fw.ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        textTheme: textTheme,
        scaffoldBackgroundColor: colors.background,
        cardColor: colors.card,
        dividerColor: colors.border,
        canvasColor: colors.card,
        splashFactory: fw.NoSplash.splashFactory,
        inputDecorationTheme: fw.InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: colors.secondary,
          border: fw.OutlineInputBorder(
            borderRadius: forui.style.borderRadius.sm,
            borderSide: fw.BorderSide(color: colors.border),
          ),
          enabledBorder: fw.OutlineInputBorder(
            borderRadius: forui.style.borderRadius.sm,
            borderSide: fw.BorderSide(color: colors.border),
          ),
          focusedBorder: fw.OutlineInputBorder(
            borderRadius: forui.style.borderRadius.sm,
            borderSide: fw.BorderSide(color: colors.primary),
          ),
        ),
        checkboxTheme: fw.CheckboxThemeData(
          side: fw.BorderSide(color: colors.border),
          fillColor: fw.WidgetStateProperty.resolveWith(
            (states) => states.contains(fw.WidgetState.selected)
                ? colors.primary
                : colors.card,
          ),
        ),
        sliderTheme: fw.SliderThemeData(
          activeTrackColor: colors.primary,
          inactiveTrackColor: colors.border,
          thumbColor: colors.primary,
        ),
        tabBarTheme: fw.TabBarThemeData(
          labelColor: colors.foreground,
          unselectedLabelColor: SemanticColor.neutral.solid(context),
          indicatorColor: colors.primary,
        ),
      ),
      child: fw.DefaultTextStyle.merge(
        style: typography.body.sm.copyWith(color: colors.foreground),
        child: child,
      ),
    );
  }
}

/// 把渲染期异常收成一个安静的错误态。
///
/// A2UI 树来自模型，形状不可信；一棵坏的树不应该让整页崩掉。
///
/// **边界在 widget 树层面是尽力而为**：Flutter 的 `build` 异常会被框架自己
/// 报告给 `FlutterError.onError`，`try/catch` 包不住子树的 `build`。真正兜底的
/// 是 `a2ui_flutter` 自己对未知 / 未解析节点返回的占位（`NodeView` 的降级）。
/// 这个边界负责的是**本组件自己的**渲染路径。
class _GenerativeErrorBoundary extends StatefulWidget {
  const _GenerativeErrorBoundary({required this.child});

  final Widget child;

  @override
  State<_GenerativeErrorBoundary> createState() =>
      _GenerativeErrorBoundaryState();
}

class _GenerativeErrorBoundaryState extends State<_GenerativeErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return Padding(
        key: const Key('generative-surface-error'),
        padding: const EdgeInsets.all(Spacing.lg),
        child: fw.Text(
          error.toString(),
          style: context.theme.typography.body.xs.copyWith(
            color: SemanticColor.destructive.solid(context),
          ),
        ),
      );
    }
    return widget.child;
  }

  /// 热重载后清掉上一次的错误：树可能已经变了，旧错误会让新树永远看不到。
  @override
  void reassemble() {
    super.reassemble();
    setState(() => _error = null);
  }
}
