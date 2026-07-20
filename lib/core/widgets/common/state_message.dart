import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';

/// 空状态/提示视图的情绪色调。
///
/// 当前主题仅提供 `primary` 与 `destructive` 两组语义色，因此：
/// - [neutral] 与 [success] 使用主色；
/// - [warning] 与 [danger] 使用破坏色（红色系）。
///
/// 未来若设计系统新增成功/警告语义色，应在此处同步更新。
enum AppStateTone { neutral, success, warning, danger }

/// 用于展示空状态、错误提示或操作引导的卡片视图。
///
/// 默认以 [FCard.raw] 包裹，图标、标题、描述垂直居中，并可附带一个轮廓按钮。
/// 通过 [maxWidth] 可限制卡片最大宽度，常用于居中的弹窗式提示。
class AppStateMessageView extends StatelessWidget {
  const AppStateMessageView({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.tone = AppStateTone.neutral,
    this.padding = const EdgeInsets.all(Spacing.level5),
    this.maxWidth,
  });

  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;
  final AppStateTone tone;
  final EdgeInsetsGeometry padding;

  /// 若提供，则在外层套 [Center] + [ConstrainedBox] 限制最大宽度。
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final accent = switch (tone) {
      AppStateTone.neutral => SemanticColor.primary,
      AppStateTone.success => SemanticColor.primary,
      AppStateTone.warning => SemanticColor.destructive,
      AppStateTone.danger => SemanticColor.destructive,
    };

    Widget message = FCard.raw(
      child: Padding(
        padding: padding,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.muted(context),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Icon(icon, color: accent.solid(context), size: 28),
                ),
              ),
              const SizedBox(height: Spacing.level4),
              Text(
                title,
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                const SizedBox(height: Spacing.level2),
                Text(
                  description!,
                  style: TypographyToken.level4
                      .body(context)
                      .copyWith(color: SemanticColor.neutral.solid(context)),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: Spacing.level5),
                FButton(
                  key: actionKey,
                  onPress: onAction,
                  variant: FButtonVariant.outline,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (maxWidth != null) {
      message = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: message,
        ),
      );
    }

    return message;
  }
}

/// 全页错误视图，在 [AppStateMessageView] 基础上增加居中与最大宽度约束。
///
/// 用于页面级错误状态（如请求失败、骨架屏超时）。
class AppStateErrorView extends StatelessWidget {
  const AppStateErrorView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.tone = AppStateTone.neutral,
    this.compact = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppStateTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final message = AppStateMessageView(
      title: title,
      description: description,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      tone: tone,
      padding: compact
          ? const EdgeInsets.all(Spacing.level4)
          : const EdgeInsets.all(Spacing.level5),
    );

    if (compact) {
      return message;
    }

    // Use LayoutBuilder so the view works both in finite-height parents
    // (e.g. the body of a non-scrollable Scaffold) and inside scrollables
    // where the incoming max height is unbounded.
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 320.0;
        return SizedBox(
          height: height,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.level4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: message,
              ),
            ),
          ),
        );
      },
    );
  }
}
