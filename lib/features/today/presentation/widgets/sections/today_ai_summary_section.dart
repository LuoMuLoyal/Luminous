import 'dart:async';

import 'package:forui/forui.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/today/domain/entities/today_ai_analysis.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/providers/today_ai_analysis_provider.dart';
import 'package:luminous/features/today/presentation/widgets/shared/today_view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayAiSummarySection extends ConsumerWidget {
  const TodayAiSummarySection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacingTokens.md,
              AppSpacingTokens.sm,
              AppSpacingTokens.md,
              AppSpacingTokens.sm,
            ),
            child: Row(
              children: [
                const TodayGlyphTile(
                  icon: FLucideIcons.sparkles,
                  color: Color(0xFF0F766E),
                  size: AppSpacingTokens.x2l,
                  radius: AppRadiusTokens.md,
                  gradient: false,
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.todayAiSummaryTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        l10n.todayAiSummarySubtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.mutedForeground,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                FButton(
                  onPress: aiState.isLoading
                      ? null
                      : () async {
                          if (!canAccessProtectedData) {
                            await pushAuthRequiredRoute(context, '/today');
                            return;
                          }

                          if (aiSummariesEnabled == false) {
                            unawaited(context.push('/settings'));
                            return;
                          }

                          final result = await ref
                              .read(todayAiAnalysisControllerProvider.notifier)
                              .generate();
                          if (!context.mounted) {
                            return;
                          }
                          if (result.status ==
                                  TodayAiAnalysisCardStatus.error &&
                              (result.errorMessage?.isNotEmpty ?? false)) {
                            await AppToast.show(context, result.errorMessage!);
                          }
                        },
                  size: FButtonSizeVariant.xs,
                  variant: FButtonVariant.ghost,
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.border),
          if (content.summary != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacingTokens.md,
                AppSpacingTokens.sm,
                AppSpacingTokens.md,
                AppSpacingTokens.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content.summary!,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          for (var index = 0; index < content.bullets.length; index += 1) ...[
            _AiSummaryRow(item: content.bullets[index]),
            if (index < content.bullets.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacingTokens.x4l + AppSpacingTokens.sm,
                color: colors.border.withValues(alpha: 0.62),
              ),
          ],
          if (content.footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacingTokens.md,
                AppSpacingTokens.xs,
                AppSpacingTokens.md,
                AppSpacingTokens.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content.footer!,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.mutedForeground,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
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
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.color, size: AppSpacingTokens.lg),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Text(
              item.text,
              style: textTheme.bodySmall?.copyWith(
                color: colors.mutedForeground,
                letterSpacing: 0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
