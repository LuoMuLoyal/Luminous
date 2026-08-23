import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';

import '../entities/app_info.dart';

/// Repository interface for public app metadata.
///
/// These endpoints are public (no auth required).
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a successful response is a Right. The
/// endpoint returns an object whose fields may all be unconfigured (env
/// driven) — that stays a Right carrying an [AppInfo] with null fields, and
/// the About/Help pages fall back to local values. A null [AppInfo] value is
/// reserved for "no metadata available" and consumers already guard it.
abstract interface class SupportRepository {
  /// Returns application metadata, or null when no metadata is available.
  TaskEither<LucentFailure, AppInfo?> getAppInfo();
}
