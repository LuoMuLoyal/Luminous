import 'package:flutter/material.dart';

enum MedicineSearchSource { cn, drugbank }

enum MedicineSearchMatchType { ingredient, name }

enum MedicineSearchCategoryType {
  painFever,
  coldCough,
  stomach,
  supplement,
  chronic,
}

enum MedicineSearchActionType { photo, barcode, keyword, switchSource }

class MedicineSearchDashboard {
  const MedicineSearchDashboard({
    required this.query,
    required this.selectedSource,
    required this.recentKeywords,
    required this.quickActions,
    required this.categories,
    required this.results,
    required this.selectedResultId,
    required this.safetyPreview,
  });

  final String query;
  final MedicineSearchSource selectedSource;
  final List<String> recentKeywords;
  final List<MedicineSearchQuickAction> quickActions;
  final List<MedicineSearchCategory> categories;
  final List<MedicineSearchResult> results;
  final String selectedResultId;
  final MedicineSearchSafetyPreview safetyPreview;

  MedicineSearchResult get selectedResult {
    return results.firstWhere((result) => result.id == selectedResultId);
  }
}

class MedicineSearchQuickAction {
  const MedicineSearchQuickAction({
    required this.type,
    required this.icon,
    required this.accent,
  });

  final MedicineSearchActionType type;
  final IconData icon;
  final Color accent;
}

class MedicineSearchCategory {
  const MedicineSearchCategory({
    required this.type,
    required this.icon,
    required this.accent,
    required this.softColor,
  });

  final MedicineSearchCategoryType type;
  final IconData icon;
  final Color accent;
  final Color softColor;
}

class MedicineSearchResult {
  const MedicineSearchResult({
    required this.id,
    required this.source,
    required this.name,
    required this.subtitle,
    required this.summary,
    required this.tags,
    required this.matchType,
  });

  final String id;
  final MedicineSearchSource source;
  final String name;
  final String subtitle;
  final String summary;
  final List<String> tags;
  final MedicineSearchMatchType matchType;
}

class MedicineSearchSafetyPreview {
  const MedicineSearchSafetyPreview({
    required this.title,
    required this.conditions,
    required this.checklist,
  });

  final String title;
  final List<String> conditions;
  final List<String> checklist;
}
