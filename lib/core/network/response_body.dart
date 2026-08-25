import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';

/// Extracts a non-null payload from a generated-client response.
///
/// Generated API methods expose the endpoint resource directly in
/// `Response.data`; this guard keeps an absent response body descriptive.
///
/// Throws a [LucentFailure.network] with [NetworkErrorCode.emptyResponse]
/// so the presentation layer can map it to a localized string via
/// [NetworkErrorL10n]. The [message] is developer-facing English; it is
/// never shown to users directly when [NetworkErrorCode] is present.
T requireData<T>(T? data, {String? operation}) {
  if (data == null) {
    throw LucentFailure.network(
      message: operation != null
          ? 'Empty response body ($operation)'
          : 'Empty response body',
      networkErrorCode: NetworkErrorCode.emptyResponse,
    );
  }
  return data;
}
