import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Result of a PDF download + share attempt.
enum PdfDownloadResult {
  /// PDF was downloaded and the share sheet was presented.
  success,

  /// The server returned an empty PDF body.
  empty,

  /// An error occurred during download or sharing.
  failed,
}

/// Downloads a PDF from [path] via [dio] and presents the system share sheet.
///
/// Encapsulates the common logic shared between the authenticated clinic
/// summary preview dialog and the public shared clinic summary page:
///   1. GET the PDF as raw bytes (`ResponseType.bytes`).
///   2. Return [PdfDownloadResult.empty] if the body is empty.
///   3. Write the bytes to a temp file named `{fileNamePrefix}-{timestamp}.pdf`.
///   4. Present `SharePlus.instance.share` with [shareSubject].
///
/// Set [skipAuth] to `true` for public endpoints that should not attach the
/// authorization header.
///
/// Returns [PdfDownloadResult.success] on success, or [PdfDownloadResult.failed]
/// if any step throws. The caller is responsible for showing the appropriate
/// toast message.
Future<PdfDownloadResult> downloadAndSharePdf({
  required Dio dio,
  required String path,
  required String fileNamePrefix,
  required String shareSubject,
  bool skipAuth = false,
}) async {
  try {
    final response = await dio.get<List<int>>(
      path,
      options: Options(
        responseType: ResponseType.bytes,
        extra: skipAuth ? const {'skipAuthorization': true} : null,
      ),
    );
    final bytes = response.data ?? <int>[];
    if (bytes.isEmpty) {
      return PdfDownloadResult.empty;
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/$fileNamePrefix-${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: shareSubject),
    );
    return PdfDownloadResult.success;
  } catch (_) {
    return PdfDownloadResult.failed;
  }
}
