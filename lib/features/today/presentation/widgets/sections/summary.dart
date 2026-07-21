import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/ai_analysis.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/features/today/presentation/widgets/shared/section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodaySummarySection extends ConsumerStatefulWidget {
  const TodaySummarySection({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  ConsumerState<TodaySummarySection> createState() =>
      _TodaySummarySectionState();
}

class _TodaySummarySectionState extends ConsumerState<TodaySummarySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  bool _aiExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DurationTokens.widgetExpand,
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleAi() {
    setState(() => _aiExpanded = !_aiExpanded);
    _controller.toggle();
  }

  @override
  Widget build(BuildContext context) {
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
      dashboard: widget.dashboard,
      canAccessProtectedData: canAccessProtectedData,
      aiSummariesEnabled: aiSummariesEnabled,
      aiState: aiState,
    );
    final metrics = buildOverviewItems(l10n, widget.dashboard);
    final isPreview = !canAccessProtectedData;
    final actionLabel = aiState.isLoading
        ? l10n.todayAiSummaryGeneratingAction
        : aiSummariesEnabled == false || aiState.isDisabled
        ? l10n.todayAiSummaryOpenSettingsAction
        : l10n.todayAiSummaryGenerateAction;
    final hasAiContent = content.summary != null || content.bullets.isNotEmpty;

    return TodaySection(
      title: l10n.todayHealthSummaryCardTitle,
      child: FCard(
        key: const Key('today-summary-card'),
        style: todayCardStyle(context, tone: TodayCardTone.soft),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.level3,
            Spacing.level4,
            Spacing.level3,
            Spacing.level3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < metrics.length; index += 1) ...[
                    Expanded(
                      child: _CompactSummaryMetric(item: metrics[index]),
                    ),
                    if (index < metrics.length - 1)
                      const SizedBox(width: Spacing.level3),
                  ],
                ],
              ),
              const SizedBox(height: Spacing.level3),
              if (content.summary != null) ...[
                MarkdownBody(
                  data: content.summary!,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                        p: TypographyToken.level3
                            .body(context)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                ),
              ] else if (!isPreview) ...[
                Text(
                  l10n.todaySummaryFallbackNarrative,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(
                        color: colors.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
              if (hasAiContent && !_aiExpanded) ...[
                const SizedBox(height: Spacing.level1),
                _AiExpandButton(onTap: _toggleAi, l10n: l10n),
              ],
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) =>
                    FCollapsible(value: _animation.value, child: child!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Spacing.level2),
                    for (final bullet in content.bullets.take(3))
                      Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.level1),
                        child: _SummaryBullet(item: bullet),
                      ),
                    if (content.footer case final footer?)
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.level1),
                        child: Text(
                          footer,
                          style: TypographyToken.level3
                              .body(context)
                              .copyWith(color: colors.mutedForeground),
                        ),
                      ),
                    if (_aiExpanded) ...[
                      const SizedBox(height: Spacing.level2),
                      _AiExpandButton(
                        onTap: _toggleAi,
                        l10n: l10n,
                        isCollapse: true,
                      ),
                    ],
                  ],
                ),
              ),
              // --- AI action button ---
              if (!isPreview) ...[
                const SizedBox(height: Spacing.level2),
                Align(
                  alignment: Alignment.centerRight,
                  child: FButton(
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
                ),
              ],
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
      unawaited(context.push(Routes.settings));
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
      await Toast.show(context, errorMessage);
    }
  }
}

class _AiExpandButton extends StatelessWidget {
  const _AiExpandButton({
    required this.onTap,
    required this.l10n,
    this.isCollapse = false,
  });

  final VoidCallback onTap;
  final AppLocalizations l10n;
  final bool isCollapse;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCollapse
                  ? l10n.todaySuggestionHideEvidence
                  : l10n.todaySuggestionShowEvidence,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: Spacing.level1),
            AnimatedRotation(
              turns: isCollapse ? 0.25 : 0,
              duration: DurationTokens.widgetQuick,
              child: Icon(
                FLucideIcons.chevronRight,
                size: Spacing.level4,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactSummaryMetric extends StatelessWidget {
  const _CompactSummaryMetric({required this.item});

  final TodayOverviewItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(item.icon, color: item.color.solid(context), size: Spacing.level5),
        const SizedBox(width: Spacing.level2),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TypographyToken.level2
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.level1),
              Text(
                item.value,
                style: TypographyToken.level4
                    .body(context)
                    .copyWith(
                      fontWeight: item.isFallback
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: item.isFallback ? colors.mutedForeground : null,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
          padding: const EdgeInsets.only(top: Spacing.level1),
          child: Icon(
            item.icon,
            color: item.color.solid(context),
            size: Spacing.level4,
          ),
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(
          child: Text(
            item.text,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
        ),
      ],
    );
  }
}
