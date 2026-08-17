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
abstract class MedicineSearchQuickAction with _$MedicineSearchQuickAction {
  const factory MedicineSearchQuickAction({
    required MedicineSearchActionType type,
    required IconData icon,
    required SemanticColor accent,
  }) = _MedicineSearchQuickAction;
}

/// 分类快捷实体，保留但**不接入主路径**（F-12）。
///
/// 后端药品库无聚合分类字段，分类数据源未接通——调用处保持
/// `Categories(categories: const [])` 隐藏分支；待后端提供分类数据源后再接线。
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
