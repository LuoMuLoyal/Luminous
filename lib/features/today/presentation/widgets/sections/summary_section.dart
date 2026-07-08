import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/ai_analysis_provider.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodaySummarySection extends ConsumerWidget {
  const TodaySummarySection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final canAccessProtectedData = ref.watch(
      authSessionProvider.select((s) => s.canAccessProtectedData),
    );
    final aiSummariesEnabled = canAccessProtectedData
        ? ref.watch(
            userSettingsControllerProvider.select(
              (s) => s.asData?.value.aiSummariesEnabled,
            ),
          )
        : null;
    final aiState = ref.watch(todayAiAnalysisControllerProvider);
    final content = buildAiCardContent(
      l10n: l10n,
      dashboard: dashboard,
      canAccessProtectedData: canAccessProtectedData,
      aiSummariesEnabled: aiSummariesEnabled,
      aiState: aiState,
    );
    final metrics = buildOverviewItems(l10n, dashboard);
    final isPreview = !canAccessProtectedData;
    final actionLabel = aiState.isLoading
        ? l10n.todayAiSummaryGeneratingAction
        : aiSummariesEnabled == false || aiState.isDisabled
        ? l10n.todayAiSummaryOpenSettingsAction
        : l10n.todayAiSummaryGenerateAction;

    return TodaySection(
      title: l10n.todayHealthSummaryCardTitle,
      child: FCard.raw(
        key: const Key('today-summary-card'),
        style: todayCardStyle(context, tone: TodayCardTone.soft),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.todayUpdatedAt(dashboard.user.updatedAtLabel),
                      style: AppTypographyToken.level3
                          .body(context)
                          .copyWith(
                            color: colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (!isPreview)
                    FButton(
                      onPress: aiState.isLoading
                          ? null
                          : () => _handleSummaryAction(
                              context,
                              ref,
                              aiSummariesEnabled,
                            ),
                      variant: FButtonVariant.ghost,
                      size: FButtonSizeVariant.xs,
                      mainAxisSize: MainAxisSize.min,
                      child: Text(actionLabel),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < metrics.length; index += 1) ...[
                    Expanded(child: _SummaryMetric(item: metrics[index])),
                    if (index < metrics.length - 1)
                      const SizedBox(width: AppSpacingTokens.level3),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              Text(
                content.summary ?? l10n.todaySummaryFallbackNarrative,
                style: AppTypographyToken.level4
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacingTokens.level3),
              for (final bullet in content.bullets.take(2))
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacingTokens.level2,
                  ),
                  child: _SummaryBullet(item: bullet),
                ),
              if (content.footer case final footer?)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacingTokens.level1),
                  child: Text(
                    footer,
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSummaryAction(
    BuildContext context,
    WidgetRef ref,
    bool? aiSummariesEnabled,
  ) async {
    if (aiSummariesEnabled == false) {
      unawaited(context.push(AppRoutes.settings));
      return;
    }

    final result = await ref
        .read(todayAiAnalysisControllerProvider.notifier)
        .generate();

    if (!context.mounted) {
      return;
    }

    final errorMessage = result.errorMessage;
    if (result.status == TodayAiAnalysisCardStatus.error &&
        errorMessage != null &&
        errorMessage.isNotEmpty) {
      await AppToast.show(context, errorMessage);
    }
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.item});

  final TodayOverviewItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(AppRadiusTokens.level3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level3,
          vertical: AppSpacingTokens.level3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item.icon,
              color: item.color.resolve(colors),
              size: AppSpacingTokens.level4,
            ),
            const SizedBox(height: AppSpacingTokens.level2),
            Text(
              item.label,
              style: AppTypographyToken.level2
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: AppSpacingTokens.level1),
            Text(
              item.value,
              style: AppTypographyToken.level4
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBullet extends StatelessWidget {
  const _SummaryBullet({required this.item});

  final TodayAiSummaryItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacingTokens.level1),
          child: Icon(
            item.icon,
            color: item.color.resolve(colors),
            size: AppSpacingTokens.level4,
          ),
        ),
        const SizedBox(width: AppSpacingTokens.level3),
        Expanded(
          child: Text(
            item.text,
            style: AppTypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
        ),
      ],
    );
  }
}
