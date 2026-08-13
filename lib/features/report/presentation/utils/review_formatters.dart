import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
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

String reviewOutcomeLabel(AppLocalizations l10n, ReviewEventOutcome outcome) {
  return switch (outcome) {
    ReviewEventOutcome.improved => l10n.reportReviewOutcomeImproved,
    ReviewEventOutcome.unchanged => l10n.reportReviewOutcomeUnchanged,
    ReviewEventOutcome.worsened => l10n.reportReviewOutcomeWorsened,
    ReviewEventOutcome.unknown => l10n.reportReviewOutcomeUnknown,
  };
}

String reviewEventKindLabel(AppLocalizations l10n, ReviewEventKind kind) {
  return switch (kind) {
    ReviewEventKind.symptom => l10n.reportReviewKindSymptom,
    ReviewEventKind.other => l10n.reportReviewKindOther,
    ReviewEventKind.unknown => l10n.reportReviewKindUnknown,
  };
}

/// unknown section 的简短缺失原因；未知码（含 unknown_default_open_api
/// 占位符）折叠为通用文案。
String reviewReasonLabel(AppLocalizations l10n, String? reasonCode) {
  return switch (reasonCode) {
    ReviewSectionReasonCodes.noObservations =>
      l10n.reportReviewReasonNoObservations,
    ReviewSectionReasonCodes.insufficientCoverage =>
      l10n.reportReviewReasonInsufficientCoverage,
    ReviewSectionReasonCodes.noCompletedActions =>
      l10n.reportReviewReasonNoCompletedActions,
    _ => l10n.reportReviewReasonUnknown,
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

/// 数值趋势方向文案；无法识别的方向按持平处理（不宣称变化）。
String reviewTrendDirectionLabel(AppLocalizations l10n, String? direction) {
  return switch (direction) {
    'up' => l10n.reportReviewChangeDirectionUp,
    'down' => l10n.reportReviewChangeDirectionDown,
    _ => l10n.reportReviewChangeDirectionFlat,
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
  return value is Map<String, dynamic> ? value : null;
}

List<Map<String, dynamic>> reviewArgMapList(
  Map<String, dynamic> args,
  String key,
) {
  final value = args[key];
  if (value is! List) {
    return const [];
  }
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
