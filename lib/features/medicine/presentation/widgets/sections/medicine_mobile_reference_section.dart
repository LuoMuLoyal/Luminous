part of '../views/medicine_mobile_dashboard_view.dart';

class _ReferenceNotice extends StatelessWidget {
  const _ReferenceNotice({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          children: [
            const Icon(
              FLucideIcons.triangleAlert,
              color: AppColorTokens.warningDeep,
              size: AppSpacingTokens.xl,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicineReferenceNoticeTitle,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColorTokens.warningDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    l10n.medicineReferenceNoticeBody,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              FLucideIcons.chevronRight,
              color: AppColorTokens.warningDeep,
              size: AppSpacingTokens.lg,
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyTipsSection extends ConsumerWidget {
  const _SafetyTipsSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(medicineSafetyTipListProvider);

    return Column(
      key: const Key('medicine-safety-tips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: l10n.medicineSafetyTipsTitle,
          leading: const Icon(
            FLucideIcons.lightbulb,
            color: AppColorTokens.warningDeep,
            size: AppSpacingTokens.lg,
          ),
          compact: true,
          trailing: AppTextAction(
            label: l10n.medicineSafetyTipsRefreshAction,
            icon: FLucideIcons.refreshCw,
            color: AppColorTokens.gradientDevelopStart,
            onTap: tipsAsync.isLoading
                ? () {}
                : () => ref
                      .read(medicineSafetyTipListProvider.notifier)
                      .refresh(),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        FCard.raw(
          child: tipsAsync.when(
            data: (tips) => _buildTipList(context, tips),
            loading: () => _buildSkeleton(context),
            error: (error, _) => AppStateMessageView(
              title: l10n.medicineErrorTitle,
              description: l10n.medicineErrorDescription,
              icon: FLucideIcons.circleAlert,
              actionLabel: l10n.medicineSafetyTipsRefreshAction,
              onAction: () =>
                  ref.read(medicineSafetyTipListProvider.notifier).refresh(),
              tone: AppStateTone.danger,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipList(BuildContext context, List<MedicineSafetyTip> tips) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    if (tips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Text(
          l10n.medicineSafetyTipsTitle,
          style: textTheme.bodySmall?.copyWith(color: colors.mutedForeground),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < tips.length; index += 1) ...[
          _SafetyTipRow(
            tip: _SafetyTip(
              icon: medicineSafetyTipIcon(tips[index].category),
              color: medicineSafetyTipColor(tips[index].category, colors),
              text: tips[index].text,
            ),
          ),
          if (index < tips.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              indent:
                  AppSpacingTokens.md +
                  AppSpacingTokens.x3l +
                  AppSpacingTokens.md,
              color: colors.border,
            ),
        ],
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final colors = context.theme.colors;
    return Column(
      children: [
        for (var index = 0; index < 4; index += 1) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.sm,
            ),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: colors.border,
                  highlightColor: colors.background,
                  child: Container(
                    width: AppSpacingTokens.x3l,
                    height: AppSpacingTokens.x3l,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(AppSpacingTokens.md),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.md),
                const Expanded(
                  child: AppInlineSkeletonBlock(height: AppSpacingTokens.lg),
                ),
              ],
            ),
          ),
          if (index < 3)
            Divider(
              height: 1,
              thickness: 1,
              indent:
                  AppSpacingTokens.md +
                  AppSpacingTokens.x3l +
                  AppSpacingTokens.md,
              color: colors.border,
            ),
        ],
      ],
    );
  }
}

class _SafetyTipRow extends StatelessWidget {
  const _SafetyTipRow({required this.tip});

  final _SafetyTip tip;

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
          AppIconBadge(
            icon: tip.icon,
            color: tip.color,
            backgroundColor: tip.color.withValues(alpha: 0.08),
            size: AppSpacingTokens.x3l,
            iconSize: AppSpacingTokens.lg,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Text(
              tip.text,
              style: textTheme.bodySmall?.copyWith(
                color: colors.mutedForeground,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            FLucideIcons.chevronRight,
            color: colors.mutedForeground,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );
  }
}
