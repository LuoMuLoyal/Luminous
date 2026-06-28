import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/search/domain/repositories/search_repository.dart';

/// Demo-only mock implementation of [MedicineSearchRepository] used for tests.
///
/// IDs, names, and manufacturers are intentionally prefixed/marked so they
/// cannot be mistaken for real backend data or sent to production APIs.
class MockMedicineSearchRepository implements MedicineSearchRepository {
  const MockMedicineSearchRepository();

  @override
  Future<List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const [
      MedicineSearchResult(
        id: '__mock_cn_ibuprofen__',
        source: MedicineSearchSource.cn,
        name: '[DEMO] 布洛芬片',
        subtitle: '[DEMO] 0.2g*12片 · 示例药业',
        summary: '[DEMO] 示例摘要，仅用于测试搜索界面。',
        tags: <String>['示例标签'],
        matchType: MedicineSearchMatchType.ingredient,
      ),
      MedicineSearchResult(
        id: '__mock_cn_acetaminophen__',
        source: MedicineSearchSource.cn,
        name: '[DEMO] 对乙酰氨基酚片',
        subtitle: '[DEMO] 0.5g*20片 · 示例药业',
        summary: '[DEMO] 示例摘要，仅用于测试搜索界面。',
        tags: <String>['示例标签'],
        matchType: MedicineSearchMatchType.ingredient,
      ),
    ];
  }

  @override
  Future<MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) async {
    return const MedicineSearchSafetyPreview(
      title: '[DEMO] Ibuprofen',
      conditions: ['[DEMO] 安全提示示例'],
      checklist: ['[DEMO] 已阅读示例说明'],
    );
  }
}
