import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_copy.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_shared.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MineCampusServiceSection extends StatelessWidget {
  const MineCampusServiceSection({super.key, required this.dashboard, required this.l10n, required this.typography, required this.surface});
  final MineDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MineSectionTitle(title: l10n.mineCampusSectionTitle, typography: typography),
        const SizedBox(height: AppSpacingTokens.sm),
        MinePanel(
          key: const Key('mine-campus-surface'), surface: surface, padding: EdgeInsets.zero,
          child: _ServiceDividerList(entries: dashboard.campusServices, l10n: l10n, typography: typography, surface: surface),
        ),
      ],
    );
  }
}

class MinePrivacyNoticeSection extends StatelessWidget {
  const MinePrivacyNoticeSection({super.key, required this.notice, required this.l10n, required this.typography, required this.surface});
  final MinePrivacyNotice notice;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showMineToast(context, mineCopy(l10n, notice.actionKey)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color.alphaBlend(mineGreen.withValues(alpha: 0.05), surface.canvas),
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: mineGreen.withValues(alpha: 0.14)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Row(
              children: [
                Icon(notice.icon, color: mineGreen, size: AppSpacingTokens.lg),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(child: Text(mineCopy(l10n, notice.titleKey), style: typography.bodySm.copyWith(color: surface.body, letterSpacing: 0))),
                const SizedBox(width: AppSpacingTokens.sm),
                Text(mineCopy(l10n, notice.actionKey), style: typography.bodySmStrong.copyWith(color: surface.body, letterSpacing: 0)),
                Icon(Icons.chevron_right_rounded, color: surface.body, size: AppSpacingTokens.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceDividerList extends StatelessWidget {
  const _ServiceDividerList({required this.entries, required this.l10n, required this.typography, required this.surface});
  final List<MineActionEntry> entries;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < entries.length; index += 1) ...[
          _ServiceRow(entry: entries[index], l10n: l10n, typography: typography, surface: surface),
          if (index < entries.length - 1)
            Divider(height: 1, thickness: 1, indent: AppSpacingTokens.md + AppSpacingTokens.x3l + AppSpacingTokens.sm, endIndent: AppSpacingTokens.md, color: surface.hairline.withValues(alpha: 0.62)),
        ],
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.entry, required this.l10n, required this.typography, required this.surface});
  final MineActionEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final canOpen = entry.actionType != null && entry.actionTarget != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canOpen ? () => _openAction(context) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md, vertical: AppSpacingTokens.md),
          child: Row(
            children: [
              _SoftIcon(icon: entry.icon, color: entry.accent, size: AppSpacingTokens.x3l, iconSize: AppSpacingTokens.lg),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.rawTitle ?? mineCopy(l10n, entry.titleKey), style: typography.bodyMdStrong.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    Text(entry.rawSubtitle ?? mineCopy(l10n, entry.subtitleKey), style: typography.bodySm.copyWith(color: surface.body, letterSpacing: 0), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: canOpen ? surface.body : surface.mute, size: AppSpacingTokens.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAction(BuildContext context) async {
    final target = entry.actionTarget;
    if (target == null || entry.actionType == null) return;
    switch (entry.actionType!) {
      case MineActionTargetType.internal:
        pushAuthRequiredRoute(context, target);
      case MineActionTargetType.url:
      case MineActionTargetType.phone:
        final uri = Uri.tryParse(target);
        if (uri == null) { showMineToast(context, mineCopy(l10n, entry.titleKey)); return; }
        await const ExternalUrlLauncher().open(uri);
    }
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({required this.icon, required this.color, this.size = 44, this.iconSize = 22});
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadiusTokens.lg)),
    child: SizedBox.square(dimension: size, child: Icon(icon, color: color, size: iconSize)),
  );
}
