import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';

/// Attempts to parse an ISO-8601 date string into a [DateTime].
///
/// Returns `null` when [value] is `null` or empty.
DateTime? tryParseMedicineDate(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

/// Formats [date] as `yyyy-MM-dd`.
String formatMedicineDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Builds a [CurrentMedicineWriteInput] for creating a new medicine entry.
CurrentMedicineWriteInput buildMedicineCreateInput({
  required String displayName,
  String? strengthText,
  String? doseText,
  String? route,
  DateTime? startedAt,
  String? note,
}) {
  return CurrentMedicineWriteInput(
    source: HealthMedicineSource.manual,
    displayName: displayName,
    strengthText: _emptyToNull(strengthText),
    doseText: _emptyToNull(doseText),
    route: _emptyToNull(route),
    startedAt: startedAt != null ? formatMedicineDate(startedAt) : null,
    note: _emptyToNull(note),
  );
}

/// Builds a [CurrentMedicineUpdateInput] for updating an existing medicine entry.
CurrentMedicineUpdateInput buildMedicineUpdateInput({
  required String displayName,
  String? strengthText,
  String? doseText,
  String? route,
  DateTime? startedAt,
  String? note,
}) {
  return CurrentMedicineUpdateInput(
    source: HealthMedicineSource.manual,
    displayName: displayName,
    strengthText: _emptyToNull(strengthText),
    doseText: _emptyToNull(doseText),
    route: _emptyToNull(route),
    startedAt: startedAt != null ? formatMedicineDate(startedAt) : null,
    note: _emptyToNull(note),
  );
}

String? _emptyToNull(String? value) => value?.isEmpty == true ? null : value;
