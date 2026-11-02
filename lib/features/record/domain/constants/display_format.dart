/// Wire-format helpers the daily-record data layer needs when it builds request
/// keys (`yyyy-MM-dd`) from a [DateTime].
///
/// The *label* formatters (locale-aware, i18n-aware) live in `core/utils/` and
/// `features/record/application/mappers/`; `data/` must not reach for those.
library;

/// Formats [date] as the `yyyy-MM-dd` key the daily-record endpoints accept.
String formatRecordDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
