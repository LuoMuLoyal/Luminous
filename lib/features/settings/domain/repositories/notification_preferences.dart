import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';

/// Repository interface for reading and patching the user's notification
/// preferences.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; an unconfigured row and local defaults stay
/// a Right (not an error).
abstract interface class NotificationPreferencesRepository {
  TaskEither<LucentFailure, NotificationPreferences> getPreferences();

  TaskEither<LucentFailure, NotificationPreferences> patchPreferences(
    NotificationPreferencesPatch patch,
  );
}
