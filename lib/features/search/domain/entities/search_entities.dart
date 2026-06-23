import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_entities.freezed.dart';

enum MedicineSearchSource { cn, drugbank }

enum MedicineSearchMatchType { ingredient, name }

enum MedicineSearchCategoryType {
  painFever,
  coldCough,
  stomach,
  supplement,
  chronic,
}

// Deferred by Product_Vision MVP: keep photo/barcode action types because scan
// and OCR are useful later, but do not surface them until the matching camera,
// recognition, and product contract is ready.
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

  MedicineSearchResult get selectedResult {
    return results.firstWhere((result) => result.id == selectedResultId);
  }
}

@freezed
abstract class MedicineSearchQuickAction with _$MedicineSearchQuickAction {
  const factory MedicineSearchQuickAction({
    required MedicineSearchActionType type,
    required IconData icon,
    required Color accent,
  }) = _MedicineSearchQuickAction;
}

@freezed
abstract class MedicineSearchCategory with _$MedicineSearchCategory {
  const factory MedicineSearchCategory({
    required MedicineSearchCategoryType type,
    required IconData icon,
    required Color accent,
    required Color softColor,
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

@freezed
abstract class MedicineSearchSafetyPreview with _$MedicineSearchSafetyPreview {
  const factory MedicineSearchSafetyPreview({
    required String title,
    required List<String> conditions,
    required List<String> checklist,
  }) = _MedicineSearchSafetyPreview;
}
