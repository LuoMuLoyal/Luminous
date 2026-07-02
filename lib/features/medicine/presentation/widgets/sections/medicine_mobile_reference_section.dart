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
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Row(
          children: [
            const Icon(
              FLucideIcons.triangleAlert,
              color: Color(0xFFB45309),
              size: AppSpacingTokens.level6,
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicineReferenceNoticeTitle,
                    style: textTheme.titleSmall?.copyWith(
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
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
              color: Color(0xFFB45309),
              size: AppSpacingTokens.level5,
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
            color: Color(0xFFB45309),
            size: AppSpacingTokens.level5,
          ),
          compact: true,
          trailing: AppTextAction(
            label: l10n.medicineSafetyTipsRefreshAction,
            icon: FLucideIcons.refreshCw,
            color: Color(0xFF16A34A),
            onTap: tipsAsync.isLoading
                ? () {}
                : () => ref
                      .read(medicineSafetyTipListProvider.notifier)
                      .refresh(),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
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
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
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
                  AppSpacingTokens.level4 +
                  AppSpacingTokens.level8 +
                  AppSpacingTokens.level4,
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
              horizontal: AppSpacingTokens.level4,
              vertical: AppSpacingTokens.level3,
            ),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: colors.border,
                  highlightColor: colors.background,
                  child: Container(
                    width: AppSpacingTokens.level8,
                    height: AppSpacingTokens.level8,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(AppSpacingTokens.level4),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level4),
                const Expanded(
                  child: AppInlineSkeletonBlock(height: AppSpacingTokens.level5),
                ),
              ],
            ),
          ),
          if (index < 3)
            Divider(
              height: 1,
              thickness: 1,
              indent:
                  AppSpacingTokens.level4 +
                  AppSpacingTokens.level8 +
                  AppSpacingTokens.level4,
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
        horizontal: AppSpacingTokens.level4,
        vertical: AppSpacingTokens.level3,
      ),
      child: Row(
        children: [
          AppIconBadge(
            icon: tip.icon,
            color: tip.color,
            backgroundColor: tip.color.withValues(alpha: 0.08),
            size: AppSpacingTokens.level8,
            iconSize: AppSpacingTokens.level5,
          ),
          const SizedBox(width: AppSpacingTokens.level4),
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
            size: AppSpacingTokens.level5,
          ),
        ],
      ),
    );
  }
}
