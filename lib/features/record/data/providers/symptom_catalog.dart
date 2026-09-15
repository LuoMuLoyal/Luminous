import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/record/domain/constants/symptom_catalog.dart';

/// 症状目录：**源在后端**（`GET daily-records/symptom-catalog`：码、顺序与本地化文案）。
///
/// 拉取失败（离线、未登录、服务端异常）时返回空列表，调用方据此回落到本地兜底目录
/// （`fallbackSymptomCatalog`），保证快速记录不因网络不可用而失效。
final symptomCatalogProvider = FutureProvider<List<SymptomCatalogEntry>>((
  ref,
) async {
  try {
    final api = ref.watch(lucentClientProvider).dailyRecords;
    final response = await api.getSymptomCatalog();
    final items = response.data?.items ?? const [];
    return [
      for (final item in items)
        if (item.code.trim().isNotEmpty)
          SymptomCatalogEntry(code: item.code.trim(), label: item.label),
    ];
  } catch (e, st) {
    ref.read(talkerProvider).error('symptomCatalog: fetch failed: $e', st);
    return const <SymptomCatalogEntry>[];
  }
});
