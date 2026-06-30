part of '../views/medicine_mobile_dashboard_view.dart';

class _ReferenceNotice extends StatelessWidget {
  const _ReferenceNotice({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      color: Color.alphaBlend(
        surface.warningSoft.withValues(alpha: 0.44),
        surface.canvas,
      ),
      borderColor: surface.warning.withValues(alpha: 0.24),
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: surface.warning,
            size: AppSpacingTokens.xl,
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineReferenceNoticeTitle,
                  style: typography.bodyMdStrong.copyWith(
                    color: surface.warningDeep,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  l10n.medicineReferenceNoticeBody,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: surface.warningDeep,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );
  }
}

class _SafetyTipsSection extends ConsumerWidget {
  const _SafetyTipsSection({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(medicineSafetyTipListProvider);

    return Column(
      key: const Key('medicine-safety-tips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: l10n.medicineSafetyTipsTitle,
          leading: Icon(
            Icons.lightbulb_outline_rounded,
            color: surface.warning,
            size: AppSpacingTokens.lg,
          ),
          compact: true,
          trailing: AppTextAction(
            label: l10n.medicineSafetyTipsRefreshAction,
            icon: Icons.refresh_rounded,
            color: surface.link,
            onTap: tipsAsync.isLoading
                ? () {}
                : () => ref
                      .read(medicineSafetyTipListProvider.notifier)
                      .refresh(),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        AppSectionSurface(
          padding: EdgeInsets.zero,
          child: tipsAsync.when(
            data: (tips) => _buildTipList(tips),
            loading: () => _buildSkeleton(),
            error: (error, _) => AppStateMessageView(
              title: l10n.medicineErrorTitle,
              description: l10n.medicineErrorDescription,
              icon: Icons.error_outline_rounded,
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

  Widget _buildTipList(List<MedicineSafetyTip> tips) {
    if (tips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Text(
          l10n.medicineSafetyTipsTitle,
          style: typography.bodySm.copyWith(color: surface.body),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < tips.length; index += 1) ...[
          _SafetyTipRow(
            tip: _SafetyTip(
              icon: medicineSafetyTipIcon(tips[index].category),
              color: medicineSafetyTipColor(tips[index].category, surface),
              text: tips[index].text,
            ),
            typography: typography,
            surface: surface,
          ),
          if (index < tips.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              indent:
                  AppSpacingTokens.md +
                  AppSpacingTokens.x3l +
                  AppSpacingTokens.md,
              color: surface.hairline,
            ),
        ],
      ],
    );
  }

  Widget _buildSkeleton() {
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
                  baseColor: surface.hairline,
                  highlightColor: surface.canvas,
                  child: Container(
                    width: AppSpacingTokens.x3l,
                    height: AppSpacingTokens.x3l,
                    decoration: BoxDecoration(
                      color: surface.hairline,
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
              color: surface.hairline,
            ),
        ],
      ],
    );
  }
}

class _SafetyTipRow extends StatelessWidget {
  const _SafetyTipRow({
    required this.tip,
    required this.typography,
    required this.surface,
  });

  final _SafetyTip tip;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
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
              style: typography.bodySm.copyWith(
                color: surface.body,
                letterSpacing: 0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: surface.mute,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );
  }
}
