import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// ② 值得注意区：dashboard findings 的结构化摘要卡，最多 2 张。
///
/// 呈现当前周期内后端判定值得注意的变化（标题 + 正文 + 数据窗口
/// startDate–endDate）。无 findings 时给一行弃权占位，不生成长文。
/// 反馈（有用/不适用）与证据引用字段属 Wave 2，本期不做假按钮。
class ReviewNoteworthySection extends StatelessWidget {
  const ReviewNoteworthySection({
    super.key,
    required this.findings,
    required this.l10n,
    required this.startDate,
    required this.endDate,
  });

  /// 当前周期的 findings；为空时展示弃权占位。
  final List<ReviewFinding> findings;

  final AppLocalizations l10n;
  final String startDate;
  final String endDate;

  @override
  Widget build(BuildContext context) {
    if (findings.isEmpty) {
      return _AbstainRow(l10n: l10n);
    }

    final shown = findings.take(2).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewNoteworthyTitle,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Semantics(
          container: true,
          explicitChildNodes: true,
          sortKey: const OrdinalSortKey(0.2),
          child: Column(
            children: [
              for (final (index, finding) in shown.indexed) ...[
                _NoteworthyCard(
                  key: Key('review-noteworthy-${finding.kind.name}-$index'),
                  finding: finding,
                  l10n: l10n,
                  window: _windowLabel(),
                ),
                if (index < shown.length - 1)
                  const SizedBox(height: Spacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _windowLabel() => l10n.reviewNoteworthyWindow(startDate, endDate);
}

class _NoteworthyCard extends StatelessWidget {
  const _NoteworthyCard({
    super.key,
    required this.finding,
    required this.l10n,
    required this.window,
  });

  final ReviewFinding finding;
  final AppLocalizations l10n;
  final String window;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FAvatar.raw(
                  size: Spacing.xl2,
                  child: Icon(
                    finding.icon,
                    size: Spacing.lg,
                    color: finding.color.solid(context),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    finding.title,
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(
              finding.body,
              style: typography.body.sm.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              window,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbstainRow extends StatelessWidget {
  const _AbstainRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FCard(
      style: const FCardStyleDelta.delta(
        padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Text(
          l10n.reviewNoteworthyAbstainLabel,
          style: context.theme.typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ),
    );
  }
}
