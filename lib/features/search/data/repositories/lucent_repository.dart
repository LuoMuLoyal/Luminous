import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/search/data/datasources/remote_data_source.dart';
import 'package:luminous/features/search/data/mappers/search_mapper.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/search/domain/repositories/search_repository.dart';

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
    } catch (_) {
      return null;
    }
  }
}

/// Provider for LucentMedicineSearchRepository.
final lucentMedicineSearchRepositoryProvider =
    Provider<LucentMedicineSearchRepository>((ref) {
      return LucentMedicineSearchRepository(
        dataSource: ref.watch(medicineSearchRemoteDataSourceProvider),
        mapper: MedicineSearchMapper(),
      );
    });

/// Provider that exposes the repository through the interface.
final medicineSearchRepositoryProvider = Provider<MedicineSearchRepository>((
  ref,
) {
  return ref.watch(lucentMedicineSearchRepositoryProvider);
});

final medicineSearchRemoteDataSourceProvider =
    Provider<MedicineSearchRemoteDataSource>((ref) {
      final api = ref.watch(lucentMedicinesApiProvider);
      return MedicineSearchRemoteDataSource(api: api);
    });
