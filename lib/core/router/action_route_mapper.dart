import 'package:luminous/app/router.dart';

/// Maps backend action tokens to in-app GoRouter routes.
///
/// Supported tokens:
/// - `today` -> [AppRoutes.home]
/// - `report` -> [AppRoutes.report]
/// - `assistant` -> [AppRoutes.assistant]
/// - `medicine` -> [AppRoutes.medicine]
/// - `record` -> [AppRoutes.record]
/// - `mine` -> [AppRoutes.mine]
/// - `settings` -> [AppRoutes.settings]
/// - Any string starting with `/` is treated as an absolute route and returned as-is.
///
/// Returns `null` if the action is empty or unrecognized, letting callers decide
/// whether to ignore or show a fallback.
String? mapActionToRoute(String? action) {
  if (action == null || action.isEmpty) return null;

  return switch (action) {
    'today' => AppRoutes.home,
    'report' => AppRoutes.report,
    'assistant' => AppRoutes.assistant,
    'medicine' => AppRoutes.medicine,
    'record' => AppRoutes.record,
    'mine' => AppRoutes.mine,
    'settings' => AppRoutes.settings,
    _ => action.startsWith('/') ? action : null,
  };
}
