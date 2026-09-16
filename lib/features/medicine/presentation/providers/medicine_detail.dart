import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_detail_remote.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'medicine_detail.g.dart';

/// Loads the medication knowledge detail for [source] (`cn` | `drugbank`) and
/// [id]. The backend caches the read for 30 minutes; the client does not add
/// its own cache layer.
@riverpod
Future<MedicineDetail> medicineDetail(Ref ref, String source, String id) {
  final api = ref.watch(lucentClientProvider).medicines;
  return MedicineDetailRemoteDataSource(
    api: api,
  ).fetchDetail(id: id, source: source);
}

/// Loads the sequence payload for [source] and [id].
///
/// Deliberately a separate provider from [medicineDetail]: the payload reaches
/// ~96 KB for a drug with many targets, so it must only be requested once the
/// user actually opens the sequence section. Providers are lazy, but the
/// accordion builds its children eagerly — the widget that watches this is
/// therefore gated on the section's expanded state rather than on being built.
@riverpod
Future<MedicineSequences> medicineSequences(Ref ref, String source, String id) {
  final api = ref.watch(lucentClientProvider).medicines;
  return MedicineDetailRemoteDataSource(
    api: api,
  ).fetchSequences(id: id, source: source);
}
