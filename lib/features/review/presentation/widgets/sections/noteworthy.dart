import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// ② 值得注意区：dashboard findings 的结构化摘要卡，最多 2 张。
///
/// 呈现当前周期内后端判定值得注意的变化（标题 + 正文 + 数据窗口
/// startDate–endDate）。无 findings 时给一行弃权占位，不生成长文。
/// 反馈（有用/不适用）与证据引用字段属 Wave 2，本期不做假按钮。
class ReviewNoteworthySection extends StatelessWidget {
  const ReviewNoteworthySection({
    super.key,
    required this.findings,
    required this.l10n,
    required this.startDate,
    required this.endDate,
    this.range,
  });

  /// 当前周期的 findings；为空时展示弃权占位。
  final List<ReviewFinding> findings;

  final AppLocalizations l10n;
  final String startDate;
  final String endDate;

  /// 当前选择的时间范围。已知时在日期前加「最近 7 天 / 最近 30 天」语义标签，
  /// 用户不必自行换算起止日期。
  final ReviewDashboardRange? range;

  @override
  Widget build(BuildContext context) {
    if (findings.isEmpty) {
      return _AbstainRow(l10n: l10n);
    }

    final shown = findings.take(2).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewNoteworthyTitle,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Semantics(
          container: true,
          explicitChildNodes: true,
          sortKey: const OrdinalSortKey(0.2),
          child: Column(
            children: [
              for (final (index, finding) in shown.indexed) ...[
                _NoteworthyCard(
                  key: Key('review-noteworthy-${finding.kind.name}-$index'),
                  finding: finding,
                  l10n: l10n,
                  window: _windowLabel(context),
                ),
                if (index < shown.length - 1)
                  const SizedBox(height: Spacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 数据窗口文案：`最近 7 天 · 9月5日 – 9月11日`。
  ///
  /// 日期按 locale 格式化（此前直接透出服务端的 ISO 串）；范围已知时前置语义
  /// 标签，省去用户自行换算。
  String _windowLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final start = _formatWindowDate(startDate, locale);
    final end = _formatWindowDate(endDate, locale);
    final rangeLabel = _rangeLabel();
    if (rangeLabel == null) {
      return l10n.reviewNoteworthyWindow(start, end);
    }
    return l10n.reviewNoteworthyWindowWithRange(rangeLabel, start, end);
  }

  String? _rangeLabel() {
    return switch (range) {
      ReviewDashboardRange.last7Days => l10n.reviewRangeLast7Days,
      ReviewDashboardRange.last30Days => l10n.reviewRangeLast30Days,
      ReviewDashboardRange.custom || null => null,
    };
  }

  /// Formats the server's `YYYY-MM-DD` window bound; falls back to the raw
  /// string when it is a placeholder or otherwise unparseable, so a missing
  /// window never renders as an empty label.
  ///
  /// The contract is a **local date literal**, not an instant: the backend
  /// builds it with `parseDateOnly`/`formatDateOnly` (UTC-normalized day
  /// arithmetic) and the value names the calendar day the user lived through.
  /// `DateTime.parse` would reinterpret it as an instant — and for the ISO
  /// form (`2026-08-17T00:00:00.000Z`) `DateFormat` renders it in the device
  /// timezone, so a user behind UTC would see the previous day on the card.
  /// Reading the leading date components avoids both problems: the literal is
  /// echoed back exactly as the backend stated it.
  static String _formatWindowDate(String raw, String locale) {
    final dateOnly = _dateOnlyPrefix(raw);
    if (dateOnly == null) return raw;
    final parsed = DateTime(dateOnly.$1, dateOnly.$2, dateOnly.$3);
    return DateFormat.MMMd(locale).format(parsed);
  }

  /// Extracts the leading `YYYY-MM-DD` calendar date from [raw].
  ///
  /// Returns null when [raw] is a placeholder (`----.--.--`) or carries no
  /// parseable date prefix, so the caller can echo the raw string instead.
  static (int, int, int)? _dateOnlyPrefix(String raw) {
    final match = _dateOnlyPrefixPattern.firstMatch(raw.trim());
    if (match == null) return null;
    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year == null || month == null || day == null) return null;
    // DateTime normalizes out-of-range values instead of throwing (month 13
    // becomes January of the next year), which would silently render a wrong
    // day; reject them and fall back to the raw string.
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final candidate = DateTime(year, month, day);
    if (candidate.year != year ||
        candidate.month != month ||
        candidate.day != day) {
      return null;
    }
    return (year, month, day);
  }

  static final RegExp _dateOnlyPrefixPattern = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})',
  );
}

class _NoteworthyCard extends StatelessWidget {
  const _NoteworthyCard({
    super.key,
    required this.finding,
    required this.l10n,
    required this.window,
  });

  final ReviewFinding finding;
  final AppLocalizations l10n;
  final String window;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FAvatar.raw(
                  size: Spacing.xl2,
                  child: Icon(
                    finding.icon,
                    size: Spacing.lg,
                    color: finding.color.solid(context),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    finding.title,
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(
              finding.body,
              style: typography.body.sm.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              window,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbstainRow extends StatelessWidget {
  const _AbstainRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FCard(
      style: const FCardStyleDelta.delta(
        padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Text(
          l10n.reviewNoteworthyAbstainLabel,
          style: context.theme.typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ),
    );
  }
}
