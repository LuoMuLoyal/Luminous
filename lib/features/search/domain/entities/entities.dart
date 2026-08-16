import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/design/semantic_color.dart';

part 'entities.freezed.dart';

enum MedicineSearchSource { cn, drugbank }

enum MedicineSearchMatchType { ingredient, name }

enum MedicineSearchCategoryType {
  painFever,
  coldCough,
  stomach,
  supplement,
  chronic,
}

// Photo recognition and barcode scan are live on mobile devices.
enum MedicineSearchActionType { photo, barcode, keyword, switchSource }

@freezed
abstract class MedicineSearchDashboard with _$MedicineSearchDashboard {
  const MedicineSearchDashboard._();

  const factory MedicineSearchDashboard({
    required String query,
    required MedicineSearchSource selectedSource,
    required List<String> recentKeywords,
    required List<MedicineSearchQuickAction> quickActions,
    required List<MedicineSearchCategory> categories,
    required List<MedicineSearchResult> results,
    required String selectedResultId,
    required MedicineSearchSafetyPreview safetyPreview,
  }) = _MedicineSearchDashboard;

  MedicineSearchResult? get selectedResult {
    return results.firstWhereOrNull((result) => result.id == selectedResultId);
  }
}

@freezed
abstract class MedicineSearchQuickAction with _$MedicineSearchQuickAction {
  const factory MedicineSearchQuickAction({
    required MedicineSearchActionType type,
    required IconData icon,
    required SemanticColor accent,
  }) = _MedicineSearchQuickAction;
}

@freezed
abstract class MedicineSearchCategory with _$MedicineSearchCategory {
  const factory MedicineSearchCategory({
    required MedicineSearchCategoryType type,
    required IconData icon,
    required SemanticColor accent,
    required SemanticColor softColor,
  }) = _MedicineSearchCategory;
}

@freezed
abstract class MedicineSearchResult with _$MedicineSearchResult {
  const factory MedicineSearchResult({
    required String id,
    required MedicineSearchSource source,
    required String name,
    required String subtitle,
    required String summary,
    required List<String> tags,
    required MedicineSearchMatchType matchType,
  }) = _MedicineSearchResult;
}

/// 桌面端旧预览面板（F-11 去造假）遗留的数据形态，保留但**不接入主路径**。
///
/// `conditions` 来自后端单行「规格 / 厂商」subtitle 的 `\n` 拆分、`checklist`
/// 恒为空数组——并非真实临床/安全内容，仅为历史参考。移动端不得复用本实体
/// 展示临床信息；真实内容走药品详情页（`/medicine/detail/:source/:id`）。
@freezed
abstract class MedicineSearchSafetyPreview with _$MedicineSearchSafetyPreview {
  const factory MedicineSearchSafetyPreview({
    required String title,
    required List<String> conditions,
    required List<String> checklist,
  }) = _MedicineSearchSafetyPreview;
}
