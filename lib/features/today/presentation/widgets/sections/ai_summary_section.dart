import 'dart:async';

import 'package:forui/forui.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/features/today/presentation/widgets/shared/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/ai_analysis_provider.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

class TodayAiSummarySection extends ConsumerWidget {
  const TodayAiSummarySection({super.key, required this.dashboard});

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
    final isSettingsDisabled =
        aiSummariesEnabled == false || aiState.isDisabled;
    final actionLabel = aiState.isLoading
        ? l10n.todayAiSummaryGeneratingAction
        : isSettingsDisabled
        ? l10n.todayAiSummaryOpenSettingsAction
        : l10n.todayAiSummaryGenerateAction;

    return FCard.raw(
      key: const Key('today-ai-summary-card'),
      style: todayCardStyle(context, tone: TodayCardTone.soft),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacingTokens.level4,
              AppSpacingTokens.level3,
              AppSpacingTokens.level4,
              AppSpacingTokens.level3,
            ),
            child: Row(
              children: [
                TodayGlyphTile(
                  icon: FLucideIcons.sparkles,
                  color: context.theme.colors.primary,
                  size: AppSpacingTokens.level7,
                  radius: AppRadiusTokens.level3,
                  gradient: false,
                ),
                const SizedBox(width: AppSpacingTokens.level3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.todayAiSummaryTitle,
                        style: AppTypographyToken.level5
                            .body(context)
                            .copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacingTokens.level1),
                      Text(
                        l10n.todayAiSummarySubtitle,
                        style: AppTypographyToken.level3
                            .body(context)
                            .copyWith(
                              color: colors.mutedForeground,
                              letterSpacing: 0,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level3),
                FButton(
                  onPress: aiState.isLoading
                      ? null
                      : () async {
                          if (!canAccessProtectedData) {
                            await pushAuthRequiredRoute(context, '/today');
                            return;
                          }

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
                          final errorMsg = result.errorMessage;
                          if (result.status ==
                                  TodayAiAnalysisCardStatus.error &&
                              errorMsg != null &&
                              errorMsg.isNotEmpty) {
                            await AppToast.show(context, errorMsg);
                          }
                        },
                  size: FButtonSizeVariant.xs,
                  variant: FButtonVariant.secondary,
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
          const AppDivider(),
          if (aiState.isLoading && !aiState.hasAnalysis)
            const _AiSummaryLoadingState()
          else ...[
            if (content.summary case final summary?)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacingTokens.level4,
                  AppSpacingTokens.level3,
                  AppSpacingTokens.level4,
                  AppSpacingTokens.level2,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    summary,
                    style: AppTypographyToken.level4
                        .body(context)
                        .copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                  ),
                ),
              ),
            for (var index = 0; index < content.bullets.length; index += 1) ...[
              _AiSummaryRow(item: content.bullets[index]),
              if (index < content.bullets.length - 1)
                AppDivider(color: colors.border.withValues(alpha: 0.62)),
            ],
            if (content.footer case final footer?)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacingTokens.level4,
                  AppSpacingTokens.level2,
                  AppSpacingTokens.level4,
                  AppSpacingTokens.level3,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    footer,
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(
                          color: colors.mutedForeground,
                          letterSpacing: 0,
                        ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _AiSummaryLoadingState extends StatelessWidget {
  const _AiSummaryLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.level4,
        AppSpacingTokens.level3,
        AppSpacingTokens.level4,
        AppSpacingTokens.level3,
      ),
      child: AppInlineSkeleton(
        children: [
          const AppInlineSkeletonBlock(height: 20, widthFactor: 0.72),
          for (var index = 0; index < 3; index += 1)
            const Row(
              children: [
                AppInlineSkeletonCircle(size: AppSpacingTokens.level5),
                SizedBox(width: AppSpacingTokens.level4),
                Expanded(
                  child: AppInlineSkeletonBlock(height: 16, widthFactor: 0.92),
                ),
              ],
            ),
          const AppInlineSkeletonBlock(height: 14, widthFactor: 0.48),
        ],
      ),
    );
  }
}

class _AiSummaryRow extends StatelessWidget {
  const _AiSummaryRow({required this.item});

  final TodayAiSummaryItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.level4,
        vertical: AppSpacingTokens.level3,
      ),
      child: Row(
        children: [
          Icon(
            item.icon,
            color: item.color.resolve(colors),
            size: AppSpacingTokens.level5,
          ),
          const SizedBox(width: AppSpacingTokens.level4),
          Expanded(
            child: Text(
              item.text,
              style: AppTypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground, letterSpacing: 0),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
