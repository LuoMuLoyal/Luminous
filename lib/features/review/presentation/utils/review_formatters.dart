import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Review 段落共用的展示格式化与契约参数防御性读取。
///
/// 契约的 `facts.arguments` 是 `Map<String, dynamic>`，嵌套结构在 JSON 解码
/// 后保持为 map/list。这里所有读取都做类型防御：字段缺失或类型不符时返回
/// 空值/回退值，而不是让整段渲染失败。

/// 契约日期字符串 → 短日期标签（如 `8月1日` / `Aug 1`），无法解析时原文返回。
String reviewShortDateLabel(BuildContext context, String value) {
  final locale = Localizations.localeOf(context).toString();
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  return DateFormat.MMMd(locale).format(parsed.toLocal());
}

/// 契约数据窗口边界（`YYYY-MM-DD` 或 ISO 形式 `2026-08-17T00:00:00.000Z`）
/// → 本地化短日期（`8月1日` / `Aug 1`），无法解析时原文返回。
///
/// 契约把窗口边界定义成**本地日期字面量**而不是时间点：后端用
/// `parseDateOnly` / `formatDateOnly`（UTC 归一的按日推算）生成它，值命名的
/// 就是用户经历的那一天。`DateTime.parse` + `toLocal()` 会把它读成时间点，
/// ISO 形式在 UTC 以西的设备上因此会显示成前一天；这里只读前导的
/// `YYYY-MM-DD` 分量，原样回显后端声明的日期。
///
/// 占位符（`----.--.--`）、空串或没有可解析日期前缀时回显原文，缺失的窗口
/// 不会渲染成空标签。
String reviewWindowDateLabel(BuildContext context, String raw) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final dateOnly = _dateOnlyPrefix(raw);
  if (dateOnly == null) {
    return raw;
  }
  final parsed = DateTime(dateOnly.$1, dateOnly.$2, dateOnly.$3);
  return DateFormat.MMMd(locale).format(parsed);
}

/// 提取 [raw] 的前导 `YYYY-MM-DD` 日历日期；没有可解析前缀时返回 null。
(int, int, int)? _dateOnlyPrefix(String raw) {
  final match = _dateOnlyPrefixPattern.firstMatch(raw.trim());
  if (match == null) return null;
  final year = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final day = int.tryParse(match.group(3)!);
  if (year == null || month == null || day == null) return null;
  // DateTime 会归一化越界值（13 月变成次年 1 月）而不是抛错，那会静默渲染出
  // 错误的日期；越界一律拒绝并回退原文。
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  final candidate = DateTime(year, month, day);
  if (candidate.year != year ||
      candidate.month != month ||
      candidate.day != day) {
    return null;
  }
  return (year, month, day);
}

final RegExp _dateOnlyPrefixPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');

String reviewOutcomeLabel(AppLocalizations l10n, ReviewEventOutcome outcome) {
  return switch (outcome) {
    ReviewEventOutcome.improved => l10n.reviewReviewOutcomeImproved,
    ReviewEventOutcome.unchanged => l10n.reviewReviewOutcomeUnchanged,
    ReviewEventOutcome.worsened => l10n.reviewReviewOutcomeWorsened,
    ReviewEventOutcome.unknown => l10n.reviewReviewOutcomeUnknown,
  };
}

String reviewEventKindLabel(AppLocalizations l10n, ReviewEventKind kind) {
  return switch (kind) {
    ReviewEventKind.symptom => l10n.reviewReviewKindSymptom,
    ReviewEventKind.other => l10n.reviewReviewKindOther,
    ReviewEventKind.unknown => l10n.reviewReviewKindUnknown,
  };
}

/// unknown section 的简短缺失原因；未知码（含 unknown_default_open_api
/// 占位符）折叠为通用文案。
String reviewReasonLabel(AppLocalizations l10n, String? reasonCode) {
  return switch (reasonCode) {
    ReviewSectionReasonCodes.noObservations =>
      l10n.reviewReviewReasonNoObservations,
    ReviewSectionReasonCodes.insufficientCoverage =>
      l10n.reviewReviewReasonInsufficientCoverage,
    ReviewSectionReasonCodes.noCompletedActions =>
      l10n.reviewReviewReasonNoCompletedActions,
    _ => l10n.reviewReviewReasonUnknown,
  };
}

ReviewEventOutcome reviewOutcomeFromArg(String? value) {
  return switch (value) {
    'improved' => ReviewEventOutcome.improved,
    'unchanged' => ReviewEventOutcome.unchanged,
    'worsened' => ReviewEventOutcome.worsened,
    _ => ReviewEventOutcome.unknown,
  };
}

/// 数值趋势方向文案；方向缺失或无法识别时如实显示「方向未知」，
/// 不伪装成「持平」。
String reviewTrendDirectionLabel(AppLocalizations l10n, String? direction) {
  return switch (direction) {
    'up' => l10n.reviewReviewChangeDirectionUp,
    'down' => l10n.reviewReviewChangeDirectionDown,
    'flat' => l10n.reviewReviewChangeDirectionFlat,
    _ => l10n.reviewReviewChangeDirectionUnknown,
  };
}

String reviewTrendValueLabel(num? value, {int fractionDigits = 0}) {
  if (value == null) {
    return '–';
  }
  return value.toStringAsFixed(fractionDigits);
}

int reviewArgInt(Map<String, dynamic> args, String key, {int fallback = 0}) {
  final value = args[key];
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

num? reviewArgNum(Map<String, dynamic> args, String key) {
  final value = args[key];
  if (value is num) {
    return value;
  }
  if (value is String) {
    return num.tryParse(value);
  }
  return null;
}

String? reviewArgString(Map<String, dynamic> args, String key) {
  final value = args[key];
  return value is String ? value : null;
}

bool reviewArgBool(
  Map<String, dynamic> args,
  String key, {
  bool fallback = false,
}) {
  final value = args[key];
  return value is bool ? value : fallback;
}

Map<String, dynamic>? reviewArgMap(Map<String, dynamic> args, String key) {
  final value = args[key];
  if (value is Map<String, dynamic>) {
    return value;
  }
  // Dart 泛型不变性：Map<String, Object> 不是 Map<String, dynamic> 的子类型。
  // JSON 解码或字面量中的嵌套 Map 运行时类型可能不匹配，需手动转换。
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

List<Map<String, dynamic>> reviewArgMapList(
  Map<String, dynamic> args,
  String key,
) {
  final value = args[key];
  if (value is! List) {
    return const [];
  }
  // 同 reviewArgMap：whereType<Map<String, dynamic>> 会滤掉
  // 运行时类型为 Map<String, Object> 的元素，需手动转换。
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList(growable: false);
}
