import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String reportDashboardDateRangeLabel(
  BuildContext context,
  String startDate,
  String endDate,
) {
  final locale = Localizations.localeOf(context).toString();
  final start = DateTime.tryParse(startDate);
  final end = DateTime.tryParse(endDate);
  if (start == null || end == null) {
    return '$startDate - $endDate';
  }
  final formatter = DateFormat.MMMd(locale);
  return '${formatter.format(start)} - ${formatter.format(end)}';
}

String reportDashboardGeneratedAtLabel(
  BuildContext context,
  String generatedAt,
) {
  final locale = Localizations.localeOf(context).toString();
  final generated = DateTime.tryParse(generatedAt)?.toLocal();
  if (generated == null) {
    return '';
  }

  return DateFormat.MMMd(locale).add_Hm().format(generated);
}
