/// Reads total physical memory for the current device.
///
/// ## Why this is an interface and not the plugin call
///
/// `device_info_plus` reports memory differently on every platform and cannot run in
/// a unit test. The picker takes this as a dependency so its "fits this device" rule
/// — which decides which models a user is offered — is testable without hardware.
abstract interface class DeviceMemoryProbe {
  /// Total physical memory in gigabytes, or null when unknown.
  ///
  /// Null means "unknown", not "none": callers treat it as "assume it fits" rather
  /// than hiding the feature on a platform whose probe is unavailable.
  Future<int?> totalMemoryGb();
}
