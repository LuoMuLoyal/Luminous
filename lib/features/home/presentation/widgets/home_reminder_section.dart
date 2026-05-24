part of '../home.dart';

/// “今日提醒”卡片区域。
class HomeReminderSection extends StatelessWidget {
  const HomeReminderSection({super.key, required this.items});

  final List<HomeReminderItemData> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final emptyText = l10n?.homeNoReminder ?? 'No reminders';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          final minListHeight =
              (compact ? 48.0 : 54.0) * 3 + (compact ? 6.0 : 8.0) * 2;
          return AppSectionCard(
            accentColor: Color.lerp(scheme.tertiary, scheme.primary, 0.35)!,
            secondaryColor: Color.lerp(scheme.primary, scheme.secondary, 0.45)!,
            ornamentKey: 'home.reminders',
            padding: EdgeInsets.all(compact ? 10 : 12),
            radius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.homeReminderTitle ?? '今日提醒',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: compact ? 5 : 7),
                if (items.isEmpty)
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minListHeight),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 10 : 12,
                        vertical: compact ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: appTintedSurface(
                          context,
                          scheme.primary,
                          lightAlpha: 0.08,
                          darkAlpha: 0.16,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: appTintedBorder(
                            context,
                            scheme.primary,
                            lightAlpha: 0.12,
                            darkAlpha: 0.22,
                          ),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        emptyText,
                        style: TextStyle(
                          fontSize: compact ? 13 : 13.5,
                          color: _homeSecondaryTextColor(
                            context,
                            emphasis: 0.30,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minListHeight),
                    child: Column(
                      children: items
                          .asMap()
                          .entries
                          .map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == items.length - 1
                                    ? 0
                                    : (compact ? 6 : 8),
                              ),
                              child: _HomeReminderTile(
                                item: item,
                                compact: compact,
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeReminderTile extends StatelessWidget {
  const _HomeReminderTile({required this.item, required this.compact});

  final HomeReminderItemData item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final titleColor = scheme.onSurface;
    final subtitleColor = _homeSecondaryTextColor(context, emphasis: 0.28);
    final idleTint = Color.lerp(scheme.primary, scheme.secondary, 0.34)!;
    final doneTint = Color.lerp(scheme.tertiary, scheme.primary, 0.45)!;
    final idleBackground = appTintedSurface(
      context,
      idleTint,
      lightAlpha: 0.11,
      darkAlpha: 0.19,
    );
    final idleBorder = appTintedBorder(
      context,
      idleTint,
      lightAlpha: 0.22,
      darkAlpha: 0.33,
    );
    final doneBackground = appTintedSurface(
      context,
      doneTint,
      lightAlpha: 0.12,
      darkAlpha: 0.20,
    );
    final doneBorder = appTintedBorder(
      context,
      doneTint,
      lightAlpha: 0.23,
      darkAlpha: 0.35,
    );
    final idleIconTint = Color.lerp(
      const Color(0xFF0284C7),
      scheme.primary,
      0.45,
    )!;
    final doneIconTint = Color.lerp(
      const Color(0xFF16A34A),
      scheme.tertiary,
      0.40,
    )!;
    final idleIconBackground = appTintedSurface(
      context,
      idleIconTint,
      lightAlpha: 0.19,
      darkAlpha: 0.28,
    );
    final doneIconBackground = appTintedSurface(
      context,
      doneIconTint,
      lightAlpha: 0.20,
      darkAlpha: 0.29,
    );
    final idleIconColor = Color.lerp(
      const Color(0xFF0284C7),
      scheme.primary,
      0.28,
    )!;
    final doneIconColor = Color.lerp(
      const Color(0xFF16A34A),
      scheme.tertiary,
      0.30,
    )!;
    final statusIdleColor = Color.lerp(
      const Color(0xFFF59E0B),
      scheme.secondary,
      0.24,
    )!;
    final statusDoneColor = Color.lerp(
      const Color(0xFF16A34A),
      scheme.tertiary,
      0.30,
    )!;
    final subtitleText = item.subtitle.trim().isNotEmpty
        ? item.subtitle.trim()
        : item.dosage.trim().isNotEmpty
        ? (l10n?.reminderDosePrefix(item.dosage.trim()) ??
              '剂量: ${item.dosage.trim()}')
        : '-';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 7 : 10,
      ),
      decoration: BoxDecoration(
        color: item.done ? doneBackground : idleBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.done ? doneBorder : idleBorder),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 28 : 32,
            height: compact ? 28 : 32,
            decoration: BoxDecoration(
              color: item.done ? doneIconBackground : idleIconBackground,
              borderRadius: BorderRadius.circular(compact ? 8 : 9),
            ),
            child: Icon(
              item.icon,
              color: item.done ? doneIconColor : idleIconColor,
              size: compact ? 16 : 18,
            ),
          ),
          SizedBox(width: compact ? 7 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: compact ? 13.2 : 14,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 1.5 : 2),
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: compact ? 11.2 : 12,
                    color: subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.done ? statusDoneColor : statusIdleColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
