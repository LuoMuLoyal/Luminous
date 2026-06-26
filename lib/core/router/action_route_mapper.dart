/// Maps backend action tokens to in-app GoRouter routes.
///
/// Supported tokens:
/// - `today` -> `/`
/// - `report` -> `/report`
/// - `assistant` -> `/assistant`
/// - `medicine` -> `/medicine`
/// - `record` -> `/record`
/// - `mine` -> `/mine`
/// - `settings` -> `/settings`
/// - Any string starting with `/` is treated as an absolute route and returned as-is.
///
/// Returns `null` if the action is empty or unrecognized, letting callers decide
/// whether to ignore or show a fallback.
String? mapActionToRoute(String? action) {
  if (action == null || action.isEmpty) return null;

  return switch (action) {
    'today' => '/',
    'report' => '/report',
    'assistant' => '/assistant',
    'medicine' => '/medicine',
    'record' => '/record',
    'mine' => '/mine',
    'settings' => '/settings',
    _ => action.startsWith('/') ? action : null,
  };
}
