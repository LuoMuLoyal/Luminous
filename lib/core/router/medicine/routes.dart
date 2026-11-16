/// Medicine deep-link paths consumed from outside the `medicine` feature.
///
/// `core/` may not import `features/`, and a feature may not import another
/// feature's `presentation/`, so callers that need to land on a medicine page
/// (the scan results / barcode flows) push these paths instead of constructing
/// `MedicineDetailRoute` / `MedicineReminderDetailRoute` from
/// `features/medicine/presentation/routes.dart`.
///
/// The literals mirror the `@TypedGoRoute` declarations in that file; drift is
/// guarded by `test/core/router/medicine_routes_test.dart`, which compares them
/// against the real typed routes.
library;

/// Same encoding `Uri.encodeComponent` applies in the typed route's
/// `location` getter, so the built path is byte-identical to it.
String _segment(String value) => Uri.encodeComponent(value);

abstract final class MedicineRoutes {
  /// `/medicine/detail/:source/:id`.
  static String detail({required String source, required String id}) =>
      '/medicine/detail/${_segment(source)}/${_segment(id)}';

  /// `/medicine/reminders/:medicineId`.
  static String reminder(String medicineId) =>
      '/medicine/reminders/${_segment(medicineId)}';
}
