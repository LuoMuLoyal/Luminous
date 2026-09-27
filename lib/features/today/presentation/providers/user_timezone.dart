/// Reads the user's IANA timezone from the health context snapshot.
///
/// Lives in the `today` feature rather than `core/utils` because it is derived
/// state: it depends on `healthContextSnapshotProvider`, and `core` must not
/// import a feature (see the `layered_import` rule). The pure date helpers that
/// have no provider dependency — [`localDateKey`] — stay in
/// `core/utils/local_date.dart` and remain importable from anywhere.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';

/// Returns the user's IANA timezone, or `null` when the snapshot is
/// unavailable (e.g. network failure).
///
/// Callers fall back to the backend's default timezone instead of crashing, so
/// that a health-context fetch failure cannot produce a different device-local
/// date from the one the backend considers "today".
Future<String?> readUserTimezone(WidgetRef ref) async {
  final cached = ref.read(healthContextSnapshotProvider);
  if (cached.hasValue) return cached.value!.profile.timezone;
  try {
    return (await ref.read(
      healthContextSnapshotProvider.future,
    )).profile.timezone;
  } catch (_) {
    return null;
  }
}
