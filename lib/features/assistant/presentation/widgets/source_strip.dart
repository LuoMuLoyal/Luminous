import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Collapsible source strip shown under assistant messages that used tools.
///
/// The collapsed row lists the tools referenced by the reply; expanding it
/// reveals the per-tool result envelope (coverage / confidence / ambiguities /
/// source tables / disclaimer) delivered by the SSE result event's optional
/// `toolDetails` field.
class AssistantSourceStrip extends StatefulWidget {
  const AssistantSourceStrip({
    super.key,
    required this.usedTools,
    required this.toolDetails,
  });

  final List<String> usedTools;
  final List<AssistantToolDetail> toolDetails;

  @override
  State<AssistantSourceStrip> createState() => _AssistantSourceStripState();
}

class _AssistantSourceStripState extends State<AssistantSourceStrip> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.usedTools.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          label: _expanded
              ? l10n.assistantSourceCollapseAction
              : l10n.assistantSourceExpandAction,
          child: GestureDetector(
            key: const Key('assistant-source-strip'),
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
              child: Row(
                children: [
                  Icon(
                    SemanticIcons.statusInfo,
                    size: 14,
                    color: SemanticColor.neutral.solid(context),
                  ),
                  const SizedBox(width: Spacing.level2),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: context.theme.typography.body.xs2.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                        children: _collapsedRowSpans(context, l10n),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Spacing.level2),
                  Icon(
                    _expanded
                        ? SemanticIcons.actionCollapse
                        : SemanticIcons.actionExpand,
                    size: 14,
                    color: SemanticColor.neutral.solid(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_hasMedicalQaTool) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.level2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 14),
                const SizedBox(width: Spacing.level2),
                Expanded(
                  child: Text(
                    l10n.assistantSourceLowTrustHint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.xs2.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_expanded)
          for (final tool in widget.usedTools)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.level3),
              child: _ToolDetailCard(
                tool: tool,
                label: _labelFor(tool),
                detail: _detailFor(tool),
              ),
            ),
      ],
    );
  }

  bool get _hasMedicalQaTool => widget.usedTools.any(
    (tool) =>
        knowledgeSourceTypeOf(tool) == AssistantKnowledgeSourceType.medicalQa,
  );

  /// Inline spans for the collapsed row: localized tool names separated by
  /// ` · `, each knowledge tool followed by its trust-tier badge.
  List<InlineSpan> _collapsedRowSpans(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final spans = <InlineSpan>[
      TextSpan(text: '${l10n.assistantUsedToolsLabel}: '),
    ];
    for (var i = 0; i < widget.usedTools.length; i++) {
      final tool = widget.usedTools[i];
      if (i > 0) {
        spans.add(const TextSpan(text: ' · '));
      }
      spans.add(TextSpan(text: _toolDisplayName(tool)));
      final tier = knowledgeSourceTypeOf(tool);
      if (tier != null) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(left: Spacing.level1),
              child: _SourceTierBadge(type: tier),
            ),
          ),
        );
      }
    }
    return spans;
  }

  String _toolDisplayName(String tool) {
    final label = _labelFor(tool);
    final localized = localizeToolName(tool, context);
    return label == null ? localized : '$localized($label)';
  }

  String? _labelFor(String tool) {
    for (final detail in widget.toolDetails) {
      final label = detail.label;
      if (detail.name == tool && label != null && label.isNotEmpty) {
        return label;
      }
    }
    return null;
  }

  AssistantToolDetail? _detailFor(String tool) {
    for (final detail in widget.toolDetails) {
      if (detail.name == tool) {
        return detail;
      }
    }
    return null;
  }
}

/// Read-only per-tool envelope card inside the expanded source strip.
class _ToolDetailCard extends StatelessWidget {
  const _ToolDetailCard({
    required this.tool,
    required this.label,
    required this.detail,
  });

  final String tool;
  final String? label;
  final AssistantToolDetail? detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final l10n = AppLocalizations.of(context)!;
    final localized = localizeToolName(tool, context);
    final title = label == null ? localized : '$localized($label)';

    final rows = <String>[];
    final detail = this.detail;
    if (detail != null) {
      final coverageStatus = _coverageStatusText(l10n, detail.coverageStatus);
      if (coverageStatus != null) {
        final reason = detail.coverageReason;
        rows.add(
          '${l10n.assistantSourceCoverageLabel}: $coverageStatus'
          '${reason != null && reason.isNotEmpty ? ' $reason' : ''}',
        );
      }
      final confidenceLevel = _confidenceLevelText(
        l10n,
        detail.confidenceLevel,
      );
      if (confidenceLevel != null) {
        final reason = detail.confidenceReason;
        rows.add(
          '${l10n.assistantSourceConfidenceLabel}: $confidenceLevel'
          '${reason != null && reason.isNotEmpty ? ' $reason' : ''}',
        );
      }
      if (detail.ambiguities.isNotEmpty) {
        rows.add(
          '${l10n.assistantSourceAmbiguitiesLabel}: '
          '${detail.ambiguities.join(', ')}',
        );
      }
      if (detail.sourceTables.isNotEmpty) {
        rows.add(
          '${l10n.assistantSourceSourceLabel}: '
          '${detail.sourceTables.join(', ')}',
        );
      }
      final generatedAt = detail.sourceGeneratedAt;
      if (generatedAt != null && generatedAt.isNotEmpty) {
        rows.add(
          '${l10n.assistantSourceGeneratedAtLabel}: '
          '${_formatGeneratedAt(context, generatedAt)}',
        );
      }
      // F-14:摘要工具的数据截至信息 —— confidenceNote 非空直接显示,
      // 否则 sourceVersion 非空显示「版本 <v>」。两者都缺时不渲染该行。
      final dataAsOf = _dataAsOfText(l10n, detail);
      if (dataAsOf != null) {
        rows.add('${l10n.assistantSourceDataAsOfLabel}: $dataAsOf');
      }
    }

    final disclaimer = detail?.disclaimer;

    return DecoratedBox(
      key: Key('assistant-source-tool-$tool'),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: context.theme.style.borderRadius.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level1),
            if (detail == null)
              Text(
                l10n.assistantSourceNoDetailsNote,
                style: typography.body.sm.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              )
            else ...[
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.level1),
                  child: Text(
                    row,
                    style: typography.body.sm.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ),
              if (disclaimer != null && disclaimer.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.level1),
                  child: Text(
                    disclaimer,
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String? _coverageStatusText(AppLocalizations l10n, String? status) {
    return switch (status) {
      'complete' => l10n.assistantSourceCoverageComplete,
      'partial' => l10n.assistantSourceCoveragePartial,
      'empty' => l10n.assistantSourceCoverageEmpty,
      null => null,
      _ => status,
    };
  }

  String? _confidenceLevelText(AppLocalizations l10n, String? level) {
    return switch (level) {
      'high' => l10n.assistantSourceConfidenceHigh,
      'medium' => l10n.assistantSourceConfidenceMedium,
      'low' => l10n.assistantSourceConfidenceLow,
      null => null,
      _ => level,
    };
  }

  String _formatGeneratedAt(BuildContext context, String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    return formatAssistantDateTimeShort(
      Localizations.localeOf(context),
      parsed,
    );
  }

  /// F-14 数据截至文本:confidenceNote 非空直接显示;否则 sourceVersion
  /// 非空显示「`版本 <v>`」;两者都缺返回 null(不渲染)。
  String? _dataAsOfText(AppLocalizations l10n, AssistantToolDetail detail) {
    final note = detail.confidenceNote;
    if (note != null && note.isNotEmpty) {
      return note;
    }
    final version = detail.sourceVersion;
    if (version != null && version.isNotEmpty) {
      return '${l10n.assistantSourceVersionLabel} $version';
    }
    return null;
  }
}

/// Small rounded badge labeling a knowledge tool's trust tier, rendered next
/// to the tool name in the collapsed source strip row.
///
/// Tone by tier:
/// - leaflet (primary): highest trust — package-insert facts, so the brand
///   color reads as the trustworthy default.
/// - drugbank (neutral secondary): scientific grounding, informational.
/// - medicalQa (destructive): open corpus, low-trust educational reference —
///   the alert tone reminds users not to treat QA material as conclusions.
class _SourceTierBadge extends StatelessWidget {
  const _SourceTierBadge({required this.type});

  final AssistantKnowledgeSourceType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;

    final (label, background, foreground) = switch (type) {
      AssistantKnowledgeSourceType.leaflet => (
        l10n.assistantSourceBadgeLeaflet,
        SemanticColor.primary.subtle(context),
        SemanticColor.primary.solid(context),
      ),
      AssistantKnowledgeSourceType.drugbank => (
        l10n.assistantSourceBadgeDrugbank,
        colors.secondary,
        SemanticColor.neutral.solid(context),
      ),
      AssistantKnowledgeSourceType.medicalQa => (
        l10n.assistantSourceBadgeMedicalQa,
        SemanticColor.destructive.subtle(context),
        SemanticColor.destructive.solid(context),
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: context.theme.style.borderRadius.xs,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level2,
          vertical: 1,
        ),
        child: Text(
          label,
          style: context.theme.typography.body.xs3.copyWith(
            color: foreground,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
