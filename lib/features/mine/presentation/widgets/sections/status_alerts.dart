import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/soft_icon.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Mine「档案提醒」状态卡组（改造项 6, C-3）。
///
/// Rendered between [MineAccountHero] and [MineArchiveSection] when
/// `dashboard.alerts` is non-empty. Each row shows icon + title + subtitle
/// (real [MineStatusCard.items] joined for allergy/medicine, truncated to the
/// first two + a「等 N 项/种」suffix; otherwise [subtitleKey] copy) and a
/// right-aligned badge (authoritative [MineStatusCard.count] copy for
/// allergy/medicine; otherwise [badgeKey] copy). Row style mirrors the archive
/// entries (SoftIcon + w700 title + muted subtitle).
///
/// 本地化与截断是展示层职责:data 层只携带结构化 items/count/kind。
class MineStatusAlertsSection extends StatelessWidget {
  const MineStatusAlertsSection({super.key, required this.alerts});

  final List<MineStatusCard> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      key: const Key('mine-status-alerts-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FCard(
          style: const FCardStyleDelta.delta(
            padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
          ),
          child: Column(
            children: [
              for (var i = 0; i < alerts.length; i++) ...[
                _StatusAlertRow(
                  key: Key('mine-status-alert-${alerts[i].titleKey.name}'),
                  card: alerts[i],
                ),
                if (i < alerts.length - 1) const AppDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusAlertRow extends StatelessWidget {
  const _StatusAlertRow({super.key, required this.card});

  final MineStatusCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final subtitle = _resolveSubtitle(l10n, card);
    final badge = _resolveBadge(l10n, card);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level3,
      ),
      child: Row(
        children: [
          SoftIcon(icon: card.icon, color: card.accent),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mineCopy(l10n, card.titleKey),
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: Spacing.level1),
                  Text(
                    subtitle,
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: Spacing.level2),
            Text(
              badge,
              style: context.theme.typography.body.xs.copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Resolves the row subtitle:
/// - allergy/medicine cards with non-empty [MineStatusCard.items]: first two
///   items joined by the locale separator, plus a「等 N 项/种」suffix when more
///   than two exist (count from [MineStatusCard.count]);
/// - otherwise the key-based copy ([MineStatusCard.subtitleKey]).
String? _resolveSubtitle(AppLocalizations l10n, MineStatusCard card) {
  if (card.items.isNotEmpty) {
    return _joinItems(l10n, card.kind, card.items, card.count);
  }
  final key = card.subtitleKey;
  return key == null ? null : mineCopy(l10n, key);
}

/// Joins the first two [items] with the locale separator (「、」for zh,
/// ", " for en, matching the existing Mine copy style) and appends the
/// localized「等 N 项/种」suffix when more than two exist.
String _joinItems(
  AppLocalizations l10n,
  MineStatusCardKind kind,
  List<String> items,
  int? count,
) {
  final separator = l10n.localeName == 'zh' ? '、' : ', ';
  final joined = items.take(2).join(separator);
  if (items.length <= 2) return joined;
  final total = count ?? items.length;
  return switch (kind) {
    MineStatusCardKind.allergy => '$joined${l10n.mineAlertAllergyMore(total)}',
    MineStatusCardKind.medicine =>
      '$joined${l10n.mineAlertMedicineMore(total)}',
    // Privacy cards never carry items; kept for exhaustiveness.
    MineStatusCardKind.privacy => joined,
  };
}

/// Resolves the row badge:
/// - allergy/medicine cards with an authoritative [MineStatusCard.count]:
///   the localized「N 项/种」count copy;
/// - otherwise the key-based copy ([MineStatusCard.badgeKey]).
String? _resolveBadge(AppLocalizations l10n, MineStatusCard card) {
  final count = card.count;
  if (count != null && card.kind != MineStatusCardKind.privacy) {
    return switch (card.kind) {
      MineStatusCardKind.allergy => l10n.mineAlertAllergyCount(count),
      MineStatusCardKind.medicine => l10n.mineAlertMedicineCount(count),
      MineStatusCardKind.privacy => null,
    };
  }
  final key = card.badgeKey;
  return key == null ? null : mineCopy(l10n, key);
}
