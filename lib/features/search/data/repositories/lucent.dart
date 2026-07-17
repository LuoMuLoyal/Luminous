import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/search/data/datasources/medicine_search.dart';
import 'package:luminous/features/search/data/mappers/mapper.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/domain/repositories/search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent.g.dart';

/// Lucent-backed medicine search repository.
class LucentMedicineSearchRepository implements MedicineSearchRepository {
  LucentMedicineSearchRepository({
    required this.dataSource,
    required this.mapper,
  });

  final MedicineSearchRemoteDataSource dataSource;
  final MedicineSearchMapper mapper;

  @override
  Future<List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await dataSource.search(
      source: source.name,
      query: query,
      page: page,
      pageSize: pageSize,
    );

    // Check business code
    if (response.code != 0) {
      throw Exception(
        response.message.isNotEmpty
            ? response.message
            : '搜索失败（${response.code}）',
      );
    }

    return response.data.map(mapper.dtoToResult).toList();
  }

  @override
  Future<MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) async {
    try {
      final response = await dataSource.getDetail(id: id, source: source.name);

      if (response.code != 0) return null;

      final detail = response.data;
      return MedicineSearchSafetyPreview(
        title: detail.name,
        conditions: detail.subtitle?.toString().split('\n') ?? [],
        checklist: const [],
      );
    } catch (e) {
      appTalker.error(
        'LucentMedicineSearchRepository.fetchSafetyPreview: failed: $e',
      );
      return null;
    }
  }
}

/// Provider for LucentMedicineSearchRepository.
@riverpod
LucentMedicineSearchRepository lucentMedicineSearchRepository(Ref ref) {
  return LucentMedicineSearchRepository(
    dataSource: ref.watch(medicineSearchRemoteDataSourceProvider),
    mapper: MedicineSearchMapper(),
  );
}

/// Provider that exposes the repository through the interface.
@riverpod
MedicineSearchRepository medicineSearchRepository(Ref ref) {
  return ref.watch(lucentMedicineSearchRepositoryProvider);
}

@riverpod
MedicineSearchRemoteDataSource medicineSearchRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).medicines;
  return MedicineSearchRemoteDataSource(api: api);
}
