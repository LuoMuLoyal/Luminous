import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/sheet_drag_handle.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// F-10 能力详情面板入口:桌面用对话框、移动端用底部 sheet(与 report 特征
/// 的 share 管理入口一致),内容为 [AssistantCapabilitiesPanel]。
///
/// 入口放在 assistant 页右上角动作区(设置按钮旁),与「助手设置」同属
/// 能力类入口;不使用会话抽屉头部 —— 抽屉语义是「历史会话」,能力明细与
/// 会话列表无关。
Future<void> showAssistantCapabilitiesSheet(
  BuildContext context,
  AssistantCapabilities capabilities,
) {
  final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

  if (isDesktop) {
    return showFDialog<void>(
      context: context,
      builder: (dialogContext, _, __) => DialogShell(
        maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
        builder: (_) => AssistantCapabilitiesPanel(capabilities: capabilities),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(RadiusTokens.level4),
      ),
    ),
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.85,
      child: AssistantCapabilitiesPanel(capabilities: capabilities),
    ),
  );
}

/// F-10 能力详情面板:顶部能力摘要(助手开关 / 持久化记忆 / RAG),下方列出
/// 全部工具(22 项)及各自状态 —— enabled 显示「可用」,disabled 显示
/// disabledReason 翻译(未知值显示原文)。
class AssistantCapabilitiesPanel extends StatelessWidget {
  const AssistantCapabilitiesPanel({super.key, required this.capabilities});

  final AssistantCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;
    final tools = capabilities.tools;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.level5,
          Spacing.level4,
          Spacing.level5,
          Spacing.level5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (MediaQuery.sizeOf(context).width < Breakpoints.desktop)
              const Center(child: SheetDragHandle()),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.assistantCapabilitiesAction,
                    style: TypographyToken.level7.display(context),
                  ),
                ),
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  onPress: () => Navigator.of(context).pop(),
                  child: const Icon(SemanticIcons.actionClose),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.assistantCapabilitiesSummaryTitle,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level2),
            _SummaryRow(
              label: l10n.assistantSettingsEnableTitle,
              enabled: capabilities.assistantEnabled,
            ),
            _SummaryRow(
              label: l10n.assistantSettingsMemoryTitle,
              enabled: capabilities.assistantMemoryEnabled,
            ),
            _SummaryRow(
              label: l10n.assistantCapabilitiesRagLabel,
              enabled: capabilities.ragEnabled,
            ),
            const SizedBox(height: Spacing.level4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.assistantCapabilitiesToolsTitle,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${capabilities.enabledToolCount} / ${tools.length}',
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level2),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final tool in tools) _ToolRow(tool: tool)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One summary line: label + 已启用 / 已关闭 value.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;
    final value = enabled
        ? l10n.assistantCapabilitiesEnabledValue
        : l10n.assistantCapabilitiesDisabledValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level1),
      child: Row(
        children: [
          Icon(
            enabled ? SemanticIcons.statusSuccess : SemanticIcons.statusBlocked,
            size: 14,
            color: enabled ? colors.primary : colors.mutedForeground,
          ),
          const SizedBox(width: Spacing.level2),
          Expanded(
            child: Text(label, style: TypographyToken.level4.body(context)),
          ),
          Text(
            value,
            style: TypographyToken.level3
                .body(context)
                .copyWith(
                  color: enabled ? colors.primary : colors.mutedForeground,
                ),
          ),
        ],
      ),
    );
  }
}

/// One tool row: localized name + status (可用 / disabledReason 翻译).
class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.tool});

  final AssistantToolCapability tool;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;
    final name = localizeToolName(tool.id, context);
    final status = assistantToolStatusText(l10n, tool);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.level2),
      child: DecoratedBox(
        key: Key('assistant-capability-tool-${tool.id}'),
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(RadiusTokens.level3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level3,
            vertical: Spacing.level3,
          ),
          child: Row(
            children: [
              Icon(
                tool.enabled
                    ? SemanticIcons.statusSuccess
                    : SemanticIcons.statusBlocked,
                size: 14,
                color: tool.enabled ? colors.primary : colors.mutedForeground,
              ),
              const SizedBox(width: Spacing.level2),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyToken.level3.body(context),
                ),
              ),
              const SizedBox(width: Spacing.level2),
              Flexible(
                child: Tooltip(
                  message: status,
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyToken.level2
                        .body(context)
                        .copyWith(
                          color: tool.enabled
                              ? colors.primary
                              : colors.mutedForeground,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
