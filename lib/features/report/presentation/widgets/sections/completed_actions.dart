import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/utils/review_formatters.dart';
import 'package:luminous/features/report/presentation/widgets/shared/review_section_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 「完成了什么」段落：已确认的服药槽位与结果确认记录。
///
/// 契约 fact code 为 `completed_actions`：
/// - `doseSlots`：confirmed / skipped / unconfirmed 计数（未确认不算失败）；
/// - `checkIns`：按日期升序的结果确认列表，最多展示 5 条并折叠剩余。
class CompletedActionsSection extends StatelessWidget {
  const CompletedActionsSection({super.key, required this.section});

  final ReviewSection section;

  static const factCodeCompletedActions = 'completed_actions';
  static const _maxCheckInRows = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final facts = section.facts;
    final isAvailable =
        section.state == ReviewSectionState.available &&
        facts != null &&
        facts.code == factCodeCompletedActions;

    return ReviewSectionCard(
      key: const Key('review-completed-actions-section'),
      icon: SemanticIcons.recordClipboard,
      title: l10n.reportReviewSectionCompletedActions,
      child: isAvailable
          ? _factsContent(context, l10n, facts.arguments)
          : ReviewUnknownReason(
              reason: reviewReasonLabel(l10n, section.reasonCode),
            ),
    );
  }

  Widget _factsContent(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> args,
  ) {
    final doseSlots = reviewArgMap(args, 'doseSlots') ?? const {};
    final checkIns = reviewArgMapList(args, 'checkIns');

    final confirmed = reviewArgInt(doseSlots, 'confirmed');
    final skipped = reviewArgInt(doseSlots, 'skipped');
    final unconfirmed = reviewArgInt(doseSlots, 'unconfirmed');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportReviewDoseSectionTitle,
          style: TypographyToken.level4
              .body(context)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Spacing.level2),
        ReviewFactRow(
          icon: SemanticIcons.statusDone,
          text: l10n.reportReviewDoseConfirmedLabel(confirmed),
        ),
        ReviewFactRow(
          icon: SemanticIcons.statusSkipped,
          text: l10n.reportReviewDoseSkippedLabel(skipped),
        ),
        if (unconfirmed > 0)
          ReviewFactRow(
            icon: SemanticIcons.statusPending,
            text: l10n.reportReviewDoseUnconfirmedLabel(unconfirmed),
          ),
        if (checkIns.isNotEmpty) ...[
          const SizedBox(height: Spacing.level2),
          Text(
            l10n.reportReviewCheckInSectionTitle,
            style: TypographyToken.level4
                .body(context)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Spacing.level2),
          for (final checkIn in checkIns.take(_maxCheckInRows))
            ReviewFactRow(
              icon: SemanticIcons.statusDone,
              text: l10n.reportReviewCheckInRecordLabel(
                reviewArgString(checkIn, 'date') ?? '–',
                reviewOutcomeLabel(
                  l10n,
                  reviewOutcomeFromArg(reviewArgString(checkIn, 'outcome')),
                ),
              ),
            ),
          if (checkIns.length > _maxCheckInRows)
            ReviewFactRow(
              icon: SemanticIcons.statusInfo,
              text: l10n.reportReviewMoreCountLabel(
                checkIns.length - _maxCheckInRows,
              ),
            ),
        ],
      ],
    );
  }
}
