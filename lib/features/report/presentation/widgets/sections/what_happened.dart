import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/utils/review_formatters.dart';
import 'package:luminous/features/report/presentation/widgets/shared/review_section_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 「发生了什么」段落：事件窗口内的观察事实（症状记录数、结果确认数）。
///
/// 契约 fact code 为 `health_event`；其他未知 code 或 unknown state 都渲染
/// 简短缺失原因，不显示分数或红色告警。
class WhatHappenedSection extends StatelessWidget {
  const WhatHappenedSection({super.key, required this.section});

  final ReviewSection section;

  static const factCodeHealthEvent = 'health_event';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final facts = section.facts;
    final isAvailable =
        section.state == ReviewSectionState.available &&
        facts != null &&
        facts.code == factCodeHealthEvent;

    return ReviewSectionCard(
      key: const Key('review-what-happened-section'),
      icon: SemanticIcons.recordSymptom,
      title: l10n.reportReviewSectionWhatHappened,
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
    final startedAt = reviewArgString(args, 'startedAt');
    final endedAt = reviewArgString(args, 'endedAt');
    final symptomCount = reviewArgInt(args, 'symptomRecordCount');
    final checkInCount = reviewArgInt(args, 'checkInCount');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (startedAt != null)
          ReviewFactRow(
            icon: SemanticIcons.statusPending,
            text: l10n.reportReviewWhatHappenedWindow(
              reviewShortDateLabel(context, startedAt),
              endedAt == null
                  ? l10n.reportReviewWindowUntilNow
                  : reviewShortDateLabel(context, endedAt),
            ),
          ),
        ReviewFactRow(
          icon: SemanticIcons.recordSymptom,
          text: l10n.reportReviewWhatHappenedSymptomCount(symptomCount),
        ),
        ReviewFactRow(
          icon: SemanticIcons.statusDone,
          text: l10n.reportReviewWhatHappenedCheckInCount(checkInCount),
        ),
      ],
    );
  }
}
