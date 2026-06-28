import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/search/domain/repositories/search_repository.dart';

/// Mock implementation of MedicineSearchRepository used for testing.
// TODO(high-2): Mock search results use IDs/names/manufacturers that look real and may pollute production data. Decide marking strategy or isolate in production builds.
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
        id: 'cn_ibuprofen_1',
        source: MedicineSearchSource.cn,
        name: '布洛芬片',
        subtitle: '0.2g*12片 · 石药集团欧意药业有限公司',
        summary: '用于缓解轻至中度疼痛，如头痛、关节痛、牙痛、肌肉痛、痛经等，也用于普通感冒或流感引起的发热。',
        tags: <String>['解热镇痛', '非处方药', '成人'],
        matchType: MedicineSearchMatchType.ingredient,
      ),
      MedicineSearchResult(
        id: 'cn_acetaminophen_1',
        source: MedicineSearchSource.cn,
        name: '对乙酰氨基酚片',
        subtitle: '0.5g*20片 · 上海信谊天平药业有限公司',
        summary: '用于普通感冒或流行性感冒引起的发热，也用于缓解轻至中度疼痛。',
        tags: <String>['解热镇痛', '非处方药', '成人'],
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
      title: 'Ibuprofen',
      conditions: ['安全提示（示例）', '青霉素过敏', '孕期（第2孕期）'],
      checklist: ['已阅读适应症与用法用量', '了解禁忌与注意事项'],
    );
  }
}
