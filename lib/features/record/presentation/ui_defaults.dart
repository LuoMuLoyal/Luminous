library;

/// Presentation-layer constants for the record feature.
///
/// These values are UI-facing defaults (date picker bounds, dialog sizes,
/// etc.) rather than business rules. Business-level constants belong in
/// `lib/features/record/domain/`.

/// Earliest selectable year for record date pickers and calendars.
///
/// Chosen to cover multi-decade health histories while staying well within
/// the range of realistic user data.
const int kCalendarMinYear = 2000;

/// Earliest selectable date for record date pickers and calendars.
///
/// `DateTime` constructors are not `const`, so this is a final value derived
/// from [kCalendarMinYear].
final DateTime kCalendarMinDate = DateTime(kCalendarMinYear);
