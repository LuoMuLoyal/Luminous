part of '../home.dart';

/// 首页“打卡记录”卡片区域。
class HomeCheckInRecordSection extends StatelessWidget {
  const HomeCheckInRecordSection({super.key, required this.items});

  final List<HomeCheckInRecordData> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final grouped = _groupByDate(items);
    final emptyText =
        l10n?.homeCheckInRecordsEmpty ?? 'No check-in records yet';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          final spacing = compact ? 7.0 : 9.0;
          return AppSectionCard(
            accentColor: Color.lerp(scheme.secondary, scheme.primary, 0.36)!,
            secondaryColor: Color.lerp(
              scheme.tertiary,
              scheme.secondary,
              0.42,
            )!,
            padding: EdgeInsets.all(compact ? 10 : 12),
            radius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.homeCheckInRecordsTitle ?? 'Check-in Records',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: compact ? 3 : 5),
                Text(
                  l10n?.homeCheckInRecordsSubtitle ??
                      'Daily completion and actual check-in time',
                  style: TextStyle(
                    fontSize: compact ? 12.4 : 12.9,
                    color: _homeSecondaryTextColor(context, emphasis: 0.28),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: compact ? 8 : 10),
                if (grouped.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 11 : 12,
                      vertical: compact ? 14 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        scheme.secondary,
                        lightAlpha: 0.08,
                        darkAlpha: 0.16,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appTintedBorder(
                          context,
                          scheme.secondary,
                          lightAlpha: 0.13,
                          darkAlpha: 0.22,
                        ),
                      ),
                    ),
                    child: Text(
                      emptyText,
                      style: TextStyle(
                        fontSize: compact ? 13 : 13.4,
                        color: _homeSecondaryTextColor(context, emphasis: 0.30),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Column(
                    children: grouped.entries
                        .map((entry) {
                          final dayItems = entry.value;
                          final doneCount = dayItems
                              .where((item) => item.done)
                              .length;
                          final dayLabel = _formatRecordDayLabel(
                            l10n,
                            locale,
                            entry.key,
                          );
                          final countText =
                              l10n?.homeCheckInRecordsDoneCount(
                                doneCount,
                                dayItems.length,
                              ) ??
                              '$doneCount/${dayItems.length} done';
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key == grouped.keys.last
                                  ? 0
                                  : spacing,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                compact ? 9 : 11,
                                compact ? 8 : 9,
                                compact ? 9 : 11,
                                compact ? 9 : 10,
                              ),
                              decoration: BoxDecoration(
                                color: appTintedSurface(
                                  context,
                                  scheme.primary,
                                  lightAlpha: 0.07,
                                  darkAlpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: appTintedBorder(
                                    context,
                                    scheme.primary,
                                    lightAlpha: 0.13,
                                    darkAlpha: 0.22,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        dayLabel,
                                        style: TextStyle(
                                          fontSize: compact ? 12.8 : 13.4,
                                          fontWeight: FontWeight.w800,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: appTintedSurface(
                                            context,
                                            scheme.secondary,
                                            lightAlpha: 0.13,
                                            darkAlpha: 0.20,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          countText,
                                          style: TextStyle(
                                            fontSize: 11.2,
                                            fontWeight: FontWeight.w700,
                                            color: scheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: compact ? 7 : 8),
                                  Column(
                                    children: dayItems
                                        .asMap()
                                        .entries
                                        .map((row) {
                                          final index = row.key;
                                          final item = row.value;
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom:
                                                  index == dayItems.length - 1
                                                  ? 0
                                                  : (compact ? 6 : 7),
                                            ),
                                            child: _HomeCheckInRecordTile(
                                              item: item,
                                              compact: compact,
                                              l10n: l10n,
                                            ),
                                          );
                                        })
                                        .toList(growable: false),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, List<HomeCheckInRecordData>> _groupByDate(
    List<HomeCheckInRecordData> records,
  ) {
    final grouped = <String, List<HomeCheckInRecordData>>{};
    for (final item in records) {
      grouped
          .putIfAbsent(item.dateKey, () => <HomeCheckInRecordData>[])
          .add(item);
    }
    return grouped;
  }

  String _formatRecordDayLabel(
    AppLocalizations? l10n,
    Locale locale,
    String dateKey,
  ) {
    final parsed = _parseDateKey(dateKey);
    if (parsed == null) {
      return dateKey;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(parsed.year, parsed.month, parsed.day);
    final delta = today.difference(day).inDays;
    if (delta == 0) {
      return l10n?.homeCheckInRecordsToday ?? 'Today';
    }
    if (delta == 1) {
      return l10n?.homeCheckInRecordsYesterday ?? 'Yesterday';
    }
    if (now.year == parsed.year) {
      final month = parsed.month.toString().padLeft(2, '0');
      final dayText = parsed.day.toString().padLeft(2, '0');
      return '$month/$dayText';
    }
    final month = parsed.month.toString().padLeft(2, '0');
    final dayText = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$dayText';
  }

  DateTime? _parseDateKey(String value) {
    final text = value.trim();
    if (text.length != 10) {
      return null;
    }
    final year = int.tryParse(text.substring(0, 4));
    final month = int.tryParse(text.substring(5, 7));
    final day = int.tryParse(text.substring(8, 10));
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }
}

class _HomeCheckInRecordTile extends StatelessWidget {
  const _HomeCheckInRecordTile({
    required this.item,
    required this.compact,
    required this.l10n,
  });

  final HomeCheckInRecordData item;
  final bool compact;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final doneColor = Color.lerp(
      const Color(0xFF16A34A),
      scheme.tertiary,
      0.34,
    )!;
    final pendingColor = Color.lerp(
      const Color(0xFFF59E0B),
      scheme.secondary,
      0.25,
    )!;
    final accent = item.done ? doneColor : pendingColor;
    final title = item.reminderTime.trim().isEmpty
        ? item.title.trim()
        : '${item.reminderTime.trim()} ${item.title.trim()}';
    final statusText = item.done
        ? (l10n?.homeCheckInRecordsStatusDone ?? 'Done')
        : (l10n?.homeCheckInRecordsStatusPending ?? 'Pending');
    final detailText = item.done
        ? (l10n?.homeCheckInRecordsCheckedAt(_formatClock(item.takenAt)) ??
              'Checked at ${_formatClock(item.takenAt)}')
        : (l10n?.homeCheckInRecordsNotChecked ?? 'Not checked in');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 8 : 9,
        compact ? 7 : 8,
        compact ? 8 : 9,
        compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: appTintedSurface(
          context,
          accent,
          lightAlpha: 0.09,
          darkAlpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: appTintedBorder(
            context,
            accent,
            lightAlpha: 0.16,
            darkAlpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 24 : 26,
            height: compact ? 24 : 26,
            decoration: BoxDecoration(
              color: appTintedSurface(
                context,
                accent,
                lightAlpha: 0.18,
                darkAlpha: 0.25,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              item.done ? Icons.check_rounded : Icons.schedule_rounded,
              color: accent,
              size: compact ? 14 : 15,
            ),
          ),
          SizedBox(width: compact ? 7 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.trim().isEmpty
                      ? (l10n?.checkInDefaultTitle ?? 'Medication Reminder')
                      : title,
                  style: TextStyle(
                    fontSize: compact ? 12.4 : 13.0,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    height: 1.24,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 1 : 2),
                Text(
                  detailText,
                  style: TextStyle(
                    fontSize: compact ? 11.1 : 11.6,
                    color: _homeSecondaryTextColor(context, emphasis: 0.28),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 6 : 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: appTintedSurface(
                context,
                accent,
                lightAlpha: 0.16,
                darkAlpha: 0.24,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10.8,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatClock(int? millis) {
    if (millis == null || millis <= 0) {
      return '--:--';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
