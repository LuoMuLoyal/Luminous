/// Permission status for health data access.
enum HealthPermissionStatus {
  /// User granted access to this data type.
  granted,

  /// User denied access to this data type.
  denied,

  /// The health platform is not available (e.g., Android without Health Connect).
  notAvailable,

  /// Permission has not been requested yet.
  notDetermined,
}
