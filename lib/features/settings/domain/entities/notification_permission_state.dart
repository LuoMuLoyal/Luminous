/// Permission state of the OS notification channel.
///
/// Pure value type: the platform adapter in `data/datasources/` maps the
/// plugin's own enum onto this one, so callers in `application/` and
/// `presentation/` never depend on `permission_handler`.
enum NotificationPermissionState {
  granted,
  denied,
  permanentlyDenied,
  unsupported,
}
