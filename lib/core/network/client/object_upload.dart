import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';

/// A presigned direct-to-object-storage upload: the credentials the backend
/// signed, plus where the object will live once it is PUT.
///
/// Both presign endpoints — the generic `POST /files/upload` and the
/// daily-records image variant — return the same eight fields, so the
/// transport below is written once against this shape instead of once per
/// endpoint.
class PresignedUpload {
  const PresignedUpload({
    required this.provider,
    required this.bucket,
    required this.objectKey,
    required this.uploadUrl,
    required this.headers,
    required this.publicUrl,
    required this.expiresAt,
    required this.maxSizeBytes,
  });

  /// Builds the transport shape from the generic files-upload response.
  factory PresignedUpload.fromFileUpload(CreateFileUploadResponse response) {
    return PresignedUpload(
      provider: response.provider,
      bucket: response.bucket,
      objectKey: response.objectKey,
      uploadUrl: response.uploadUrl,
      headers: response.headers,
      publicUrl: response.publicUrl,
      expiresAt: response.expiresAt,
      maxSizeBytes: response.maxSizeBytes,
    );
  }

  /// Builds the transport shape from the daily-records image response.
  factory PresignedUpload.fromDailyRecordImageUpload(
    DailyRecordImageUploadResponse response,
  ) {
    return PresignedUpload(
      provider: response.provider,
      bucket: response.bucket,
      objectKey: response.objectKey,
      uploadUrl: response.uploadUrl,
      headers: response.headers,
      publicUrl: response.publicUrl,
      expiresAt: response.expiresAt,
      maxSizeBytes: response.maxSizeBytes,
    );
  }

  final String provider;
  final String bucket;

  /// Where the object lands in the bucket, e.g. `files/{userId}/{uuid}.jpg`.
  final String objectKey;

  /// The signed **PUT** URL.
  ///
  /// This is a write-only signature: it cannot be fetched. Never hand it to a
  /// reader — use [requirePublicUrl] instead.
  final String uploadUrl;

  /// Headers the PUT must carry (the signed `Content-Type`).
  final Map<String, String> headers;

  /// The URL the object can be read back from, or `null` when the deployment
  /// configures no public base URL (`*_PUBLIC_BASE_URL`) — in which case
  /// nothing serves the object back and no URL should be invented for it.
  final String? publicUrl;

  /// Signed URL expiry timestamp (ISO 8601).
  final String expiresAt;

  /// The server's accepted upload ceiling, in bytes.
  final int maxSizeBytes;

  /// The readable URL, or a [LucentFailure] when there is none.
  ///
  /// A missing public base URL is a deployment-configuration problem, not a
  /// transport one: the object uploads fine and then cannot be read. Failing
  /// here is deliberate — the previous fallback returned [uploadUrl], which
  /// looks like a URL and cannot be fetched by anyone.
  String requirePublicUrl() {
    final url = publicUrl?.trim();
    if (url == null || url.isEmpty) {
      throw const LucentFailure(
        kind: LucentFailureKind.unknown,
        message:
            'Object storage has no public base URL configured, so the '
            'uploaded file cannot be read back.',
      );
    }
    return url;
  }
}

/// Presigns a generic file upload through the typed `POST /files/upload`.
///
/// Takes the narrow [FilesApi] dependency (callers pass `client.files`) so the
/// helper stays unit-testable without a whole [LucentClient].
///
/// Throws (a `DioException` or [LucentFailure]) so callers can wrap it in
/// `TaskEither.tryCatch` + `LucentErrorMapper.fromObject` like every other
/// request; an empty success body is a [LucentFailure] rather than a
/// transport exception, matching the rest of the network layer.
Future<PresignedUpload> presignFileUpload(
  FilesApi filesApi, {
  required String contentType,
  required int sizeBytes,
  String? fileName,
}) async {
  final response = await filesApi.createUpload(
    createUploadRequest: CreateUploadRequest(
      contentType: contentType,
      sizeBytes: sizeBytes,
      fileName: fileName,
    ),
  );
  final body = response.data;
  if (body == null) {
    throw LucentFailure.network(
      message: 'File upload presign response was empty.',
      networkErrorCode: NetworkErrorCode.emptyResponse,
    );
  }
  return PresignedUpload.fromFileUpload(body);
}

/// PUTs [bytes] to the presigned object-storage URL.
///
/// Shared by every upload path so the two "this is not the Lucent API" rules
/// live in exactly one place:
/// - the request must **not** carry the session's `Authorization` header (the
///   signature is the credential, and leaking the bearer token to a storage
///   host is both useless and unsafe);
/// - it must **not** go through the 401 refresh path — object storage cannot
///   refresh a session, and a refresh triggered by a storage 403 would spend
///   the single-use refresh token for nothing.
Future<void> putPresignedObject(
  Dio dio, {
  required PresignedUpload upload,
  required Uint8List bytes,
  required String contentType,
  int? sizeBytes,
}) async {
  // Deliberately untyped `put`: the response body is object storage's, not
  // ours, and nothing reads it.
  await dio.put(
    upload.uploadUrl,
    data: bytes,
    options: Options(
      headers: <String, Object?>{
        ...upload.headers,
        Headers.contentLengthHeader: sizeBytes ?? bytes.length,
      },
      contentType: upload.headers[Headers.contentTypeHeader] ?? contentType,
      extra: const <String, Object?>{
        'skipAuthorization': true,
        'skipAuthRefresh': true,
      },
    ),
  );
}
