import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String reportDashboardDateRangeLabel(
  BuildContext context,
  String startDate,
  String endDate,
) {
  final locale = Localizations.localeOf(context).toString();
  final start = DateTime.parse(startDate);
  final end = DateTime.parse(endDate);
  final pattern = locale.startsWith('zh') ? 'M月d日' : 'MMM d';
  final formatter = DateFormat(pattern, locale);
  return '${formatter.format(start)} - ${formatter.format(end)}';
}
