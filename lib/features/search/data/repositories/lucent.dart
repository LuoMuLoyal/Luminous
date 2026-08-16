import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/features/search/data/datasources/medicine_search.dart';
import 'package:luminous/features/search/data/mappers/medicine_search.dart';
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

    ensureEnvelopeSuccess(code: response.code, message: response.message);

    return response.data.items.map(mapper.dtoToResult).toList();
  }

  /// 桌面端旧预览面板遗留的详情拉取（F-11 去造假后保留但**不接入主路径**）。
  ///
  /// 映射逻辑原样保留仅作参考：subtitle 按 `\n` 拆分充当 `conditions`、
  /// `checklist` 恒为空、异常吞掉返回 null（失败与无数据不可区分）——这些
  /// 都不是真实临床/安全内容，移动端不得复制该造假模式；真实内容走
  /// `medicine_detail` 链路与药品详情页。
  @override
  Future<MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) async {
    try {
      final response = await dataSource.getDetail(id: id, source: source.name);

      ensureEnvelopeSuccess(code: response.code, message: response.message);

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
