import 'package:luminous/features/scan/domain/entities/scan_result.dart';

/// 纯函数：OCR 候选去重与搜库结果合并（F-4）。
///
/// 两个函数都没有副作用、不依赖平台，专为单测设计：
///
/// - [dedupeCandidates] 在**搜库之前**对候选去重。OCR 候选的「稳定身份」在
///   搜库前只有 query（同一个批准文号可能从多个文本块重复提取，同一药名
///   也可能命中多个文本块），故按规范化 query 去重即可消除重复搜索——
///   真正的稳定药品 id 去重发生在搜库结果合并阶段（[mergeSearchResults]）。
/// - [mergeSearchResults] 在**搜库之后**按稳定药品 id 合并：不同候选 query
///   可能搜到同一药品，只保留一条，避免弹窗出现重复候选。

/// 按规范化 query（trim + 小写）去重 [candidates]。
///
/// 同一规范化 query 保留 confidence 最高者；confidence 相等时保留先出现的
/// （遍历中只有严格更高才替换，天然确定性），返回顺序保持首次出现顺序。
List<MedicineMatchCandidate> dedupeCandidates(
  List<MedicineMatchCandidate> candidates,
) {
  final merged = <MedicineMatchCandidate>[];
  // 规范化 query → merged 中的下标。
  final indexByKey = <String, int>{};
  for (final candidate in candidates) {
    final key = candidate.query.trim().toLowerCase();
    final index = indexByKey[key];
    if (index == null) {
      indexByKey[key] = merged.length;
      merged.add(candidate);
    } else if (candidate.confidence > merged[index].confidence) {
      merged[index] = candidate;
    }
  }
  return merged;
}

/// 按稳定药品 id 合并 [results]。
///
/// 键规则：`id != null` 以 id 为键（稳定身份）；`id == null` 以 trim 后的
/// name 为键兜底（同一名称视为同一药品）。同键保留 confidence 最高者
/// （`confidence ?? 0` 比较，null 视为 0）；相等保留先出现的。返回顺序保持
/// 首次出现顺序（确定性），被保留结果的 matchType/来源字段原样保留。
List<MedicineMatchResult> mergeSearchResults(
  List<MedicineMatchResult> results,
) {
  final merged = <MedicineMatchResult>[];
  // 合并键 → merged 中的下标。
  final indexByKey = <String, int>{};
  for (final result in results) {
    final key = result.id != null
        ? 'id:${result.id}'
        : 'name:${result.name.trim()}';
    final index = indexByKey[key];
    if (index == null) {
      indexByKey[key] = merged.length;
      merged.add(result);
    } else if ((result.confidence ?? 0) > (merged[index].confidence ?? 0)) {
      merged[index] = result;
    }
  }
  return merged;
}
