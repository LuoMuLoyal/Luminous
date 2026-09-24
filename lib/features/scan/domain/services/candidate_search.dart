import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/repositories/scan.dart';

/// Searches every OCR candidate against the medicine database and collects the
/// hits.
///
/// A single candidate whose search fails must not sink the whole scan: OCR
/// usually yields several candidates (approval number, brand name, generic
/// name) and the remaining ones may still match, whereas failing on the first
/// Left turned one bad query into a failed scan.
///
/// A failure is still surfaced by the first failure as soon as no hit was
/// collected at all. An empty result means "this medicine is not in the
/// database" to the caller, and that claim is only true when every candidate
/// actually got an answer — otherwise an outage would be reported to the user
/// as "no medicine found".
Future<List<MedicineMatchResult>> searchCandidates(
  ScanRepository repository,
  List<MedicineMatchCandidate> candidates,
) async {
  final results = <MedicineMatchResult>[];
  LucentFailure? firstFailure;

  for (final candidate in candidates) {
    final items = (await repository.search(candidate.query).run()).fold((
      failure,
    ) {
      firstFailure ??= failure;
      return const <ScanSearchResult>[];
    }, (items) => items);

    for (final item in items) {
      results.add(
        MedicineMatchResult(
          name: item.name,
          id: item.id,
          confidence: candidate.confidence,
          matchType: candidate.matchType,
        ),
      );
    }
  }

  final failure = firstFailure;
  if (results.isEmpty && failure != null) throw failure;
  return results;
}
