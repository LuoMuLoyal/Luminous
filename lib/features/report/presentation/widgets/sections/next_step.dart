import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/utils/review_formatters.dart';
import 'package:luminous/features/report/presentation/widgets/shared/review_section_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 「接下来怎么办」段落：下一步提示与已审核的用药安全提醒。
///
/// 契约 fact code：
/// - `active_check_in`：`hasTodayCheckIn` 决定是提醒打卡还是已确认；
/// - `event_ended`：展示用户确认的最终结果；
/// - 两者都可能附带 `redFlags`（仅已审核的静态安全规则），用 warning 色调
///   逐条结构化展示，不生成任何泛化建议文案。
class NextStepSection extends StatelessWidget {
  const NextStepSection({super.key, required this.section});

  final ReviewSection section;

  static const factCodeActiveCheckIn = 'active_check_in';
  static const factCodeEventEnded = 'event_ended';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final facts = section.facts;
    final isAvailable =
        section.state == ReviewSectionState.available &&
        facts != null &&
        (facts.code == factCodeActiveCheckIn ||
            facts.code == factCodeEventEnded);

    if (!isAvailable) {
      return ReviewSectionCard(
        key: const Key('review-next-step-section'),
        icon: SemanticIcons.reportInsight,
        title: l10n.reportReviewSectionNextStep,
        child: ReviewUnknownReason(
          reason: reviewReasonLabel(l10n, section.reasonCode),
        ),
      );
    }

    final args = facts.arguments;
    final prompt = switch (facts.code) {
      factCodeActiveCheckIn =>
        reviewArgBool(args, 'hasTodayCheckIn')
            ? l10n.reportReviewNextStepCheckInDonePrompt
            : l10n.reportReviewNextStepCheckInPrompt,
      _ => l10n.reportReviewNextStepEndedPrompt(
        reviewOutcomeLabel(
          l10n,
          reviewOutcomeFromArg(reviewArgString(args, 'outcome')),
        ),
      ),
    };
    final redFlags = reviewArgMapList(args, 'redFlags');

    return ReviewSectionCard(
      key: const Key('review-next-step-section'),
      icon: SemanticIcons.reportInsight,
      title: l10n.reportReviewSectionNextStep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReviewFactRow(icon: SemanticIcons.aiTip, text: prompt),
          if (redFlags.isNotEmpty) ...[
            const SizedBox(height: Spacing.level2),
            _RedFlagList(l10n: l10n, redFlags: redFlags),
          ],
        ],
      ),
    );
  }
}

class _RedFlagList extends StatelessWidget {
  const _RedFlagList({required this.l10n, required this.redFlags});

  final AppLocalizations l10n;
  final List<Map<String, dynamic>> redFlags;

  @override
  Widget build(BuildContext context) {
    const warning = SemanticColor.warning;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: warning.subtle(context),
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
      ),
      padding: const EdgeInsets.all(Spacing.level3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  SemanticIcons.safetyAllergy,
                  size: Spacing.level4,
                  color: warning.solid(context),
                ),
              ),
              const SizedBox(width: Spacing.level2),
              // 标题参与 flex 收缩：en 长文案下避免横向溢出（Task 9 矩阵）。
              Expanded(
                child: Text(
                  l10n.reportReviewRedFlagSectionTitle,
                  style: TypographyToken.level4
                      .body(context)
                      .copyWith(
                        color: warning.solid(context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.level2),
          for (final flag in redFlags)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.level1),
              child: Text(
                _redFlagLabel(flag),
                style: TypographyToken.level3.body(context),
              ),
            ),
        ],
      ),
    );
  }

  String _redFlagLabel(Map<String, dynamic> flag) {
    final rule = reviewArgString(flag, 'rule');
    final medicineName = reviewArgString(flag, 'medicineName') ?? '–';
    final relatedLabel = reviewArgString(flag, 'relatedLabel');

    return switch (rule) {
      'severeAllergy' => l10n.reportReviewRedFlagSevereAllergy(
        medicineName,
        relatedLabel ?? '–',
      ),
      'informationGap' => l10n.reportReviewRedFlagInformationGap(medicineName),
      _ => l10n.reportReviewRedFlagUnknown(medicineName),
    };
  }
}
