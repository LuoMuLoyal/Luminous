import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/presentation/utils/record_date_time_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordOccurredAtFields extends StatelessWidget {
  const RecordOccurredAtFields({
    super.key,
    required this.date,
    required this.time,
    required this.onDateTap,
    required this.onTimeTap,
  });

  final DateTime date;
  final String? time;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FButton(
          variant: FButtonVariant.outline,
          key: const Key('record-date-field'),
          onPress: onDateTap,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${l10n.recordCreateFieldDate} · ${formatRecordDate(date)}',
            ),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FButton(
          variant: FButtonVariant.outline,
          key: const Key('record-time-field'),
          onPress: onTimeTap,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${l10n.recordCreateFieldTime} · ${formatRecordTimeLabel(time)}',
            ),
          ),
        ),
      ],
    );
  }
}
