import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/search/domain/entities/medicine_search.dart';
import 'package:luminous/features/search/domain/repositories/medicine_search_repository.dart';

class MockMedicineSearchRepository implements MedicineSearchRepository {
  const MockMedicineSearchRepository();

  @override
  Future<MedicineSearchDashboard> fetchDashboard() async {
    return const MedicineSearchDashboard(
      query: '',
      selectedSource: MedicineSearchSource.cn,
      recentKeywords: <String>[
        '布洛芬',
        '对乙酰氨基酚',
        '连花清瘟胶囊',
        '奥美拉唑',
        '维生素D',
        '蒙脱石散',
      ],
      quickActions: <MedicineSearchQuickAction>[
        MedicineSearchQuickAction(
          type: MedicineSearchActionType.photo,
          icon: Icons.photo_camera_outlined,
          accent: AppColorTokens.link,
        ),
        MedicineSearchQuickAction(
          type: MedicineSearchActionType.barcode,
          icon: Icons.qr_code_scanner_rounded,
          accent: AppColorTokens.link,
        ),
      ],
      categories: <MedicineSearchCategory>[
        MedicineSearchCategory(
          type: MedicineSearchCategoryType.painFever,
          icon: Icons.thermostat_outlined,
          accent: AppColorTokens.link,
          softColor: AppColorTokens.linkSoft,
        ),
        MedicineSearchCategory(
          type: MedicineSearchCategoryType.coldCough,
          icon: Icons.face_outlined,
          accent: Color(0xFF36A3F7),
          softColor: Color(0xFFE1F2FF),
        ),
        MedicineSearchCategory(
          type: MedicineSearchCategoryType.stomach,
          icon: Icons.set_meal_outlined,
          accent: Color(0xFFFF6D6B),
          softColor: Color(0xFFFFE4E2),
        ),
        MedicineSearchCategory(
          type: MedicineSearchCategoryType.supplement,
          icon: Icons.medication_liquid_outlined,
          accent: AppColorTokens.cyanDeep,
          softColor: AppColorTokens.cyanSoft,
        ),
        MedicineSearchCategory(
          type: MedicineSearchCategoryType.chronic,
          icon: Icons.favorite_outline_rounded,
          accent: AppColorTokens.highlightMagenta,
          softColor: AppColorTokens.errorSoft,
        ),
      ],
      results: <MedicineSearchResult>[
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
          summary: '用于普通感冒或流行性感冒引起的发热，也用于缓解轻至中度疼痛，如头痛、关节痛、偏头痛、牙痛、肌肉痛等。',
          tags: <String>['解热镇痛', '非处方药', '成人'],
          matchType: MedicineSearchMatchType.ingredient,
        ),
        MedicineSearchResult(
          id: 'drugbank_amoxicillin',
          source: MedicineSearchSource.drugbank,
          name: '阿莫西林胶囊',
          subtitle: '500mg · Amoxicillin',
          summary: '广谱青霉素类抗生素，用于敏感菌引起的多种感染，如呼吸道、泌尿道、皮肤软组织等感染。',
          tags: <String>['抗生素', '处方药'],
          matchType: MedicineSearchMatchType.name,
        ),
        MedicineSearchResult(
          id: 'cn_omeprazole_1',
          source: MedicineSearchSource.cn,
          name: '奥美拉唑肠溶胶囊',
          subtitle: '20mg*14粒 · 阿斯利康制药有限公司',
          summary: '用于消化性溃疡、反流性食管炎、卓-艾综合征等，也用于与抗生素联用根除幽门螺杆菌。',
          tags: <String>['抑酸', '处方药'],
          matchType: MedicineSearchMatchType.name,
        ),
      ],
      selectedResultId: 'cn_ibuprofen_1',
      safetyPreview: MedicineSearchSafetyPreview(
        title: '安全提示（示例）',
        conditions: <String>['青霉素过敏', '孕期（第2孕期）', '正在服用华法林'],
        checklist: <String>[
          '已阅读适应症与用法用量',
          '了解禁忌与注意事项',
          '确认与现用药无相互作用',
          '如有不适及时就医',
        ],
      ),
    );
  }
}

final medicineSearchRepositoryProvider = Provider<MedicineSearchRepository>((
  ref,
) {
  return const MockMedicineSearchRepository();
});
