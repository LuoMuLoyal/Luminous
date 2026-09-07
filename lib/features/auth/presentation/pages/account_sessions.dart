import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 会话管理部分 - 跳转到会话管理页面
class SessionManagementSection extends StatelessWidget {
  const SessionManagementSection({super.key, required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionColumn(
      title: l10n.authSessionsSectionTitle,
      children: [
        _MutedText(l10n.authSessionsSectionSubtitle),
        SizedBox(
          width: double.infinity,
          child: FButton(
            variant: FButtonVariant.outline,
            onPress: onManage,
            child: Text(l10n.authSessionsManageAction),
          ),
        ),
      ],
    );
  }
}

/// 通用组件：章节列容器
class _SectionColumn extends StatelessWidget {
  const _SectionColumn({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    header: true,
    label: title,
    // 账号页移除内层 FCard 后，各模块与外层 AuthShell 面板共用同一层背景，
    // 用语义容器 + header 为读屏用户划分模块边界（review 2026-09-06 §5）。
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.level5),
        for (final child in children) ...[
          child,
          if (child != children.last) const SizedBox(height: Spacing.level4),
        ],
      ],
    ),
  );
}

/// 通用组件：弱化文本
class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.theme.typography.body.xs.copyWith(
        color: SemanticColor.neutral.solid(context),
      ),
    );
  }
}
