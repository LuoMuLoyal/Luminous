import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/scan/domain/services/medicine_text_matcher.dart';

class MedicineRecognizeDialog extends StatefulWidget {
  const MedicineRecognizeDialog({
    super.key,
    required this.imagePath,
    required this.methodLabel,
    required this.results,
    required this.onRetake,
  });

  final String imagePath;
  final String methodLabel;
  final List<MedicineMatchResult> results;
  final VoidCallback onRetake;

  @override
  State<MedicineRecognizeDialog> createState() =>
      _MedicineRecognizeDialogState();
}

class _MedicineRecognizeDialogState extends State<MedicineRecognizeDialog> {
  bool _showCandidateList = false;
  int? _selectedIndex;

  MedicineMatchResult? get _topResult =>
      widget.results.isNotEmpty ? widget.results.first : null;

  List<MedicineMatchResult> get _sortedResults {
    final seen = <String>{};
    return widget.results.where((r) => seen.add(r.name)).toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final top = _topResult;
    final sorted = _sortedResults;

    return FDialog(
      title: const Text('识别结果'),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
                  child: Image.file(
                    File(widget.imagePath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('识别结果', style: typography.body.md),
                      Text(
                        '来源: ${widget.methodLabel}',
                        style: typography.body.sm.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level5),

            if (top != null) ...[
              // Top result card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacingTokens.level4),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.level3),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('药品', top.name),
                    if (top.approvalNumber != null)
                      _infoRow('批准文号', top.approvalNumber!),
                    const SizedBox(height: AppSpacingTokens.level2),
                    Text(
                      '置信度: ${(top.confidence * 100).toInt()}%',
                      style: typography.body.sm.copyWith(color: colors.primary),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text('未能识别到药品信息', style: typography.body.md),
            ],

            const SizedBox(height: AppSpacingTokens.level4),

            // Candidate list expander
            if (sorted.length > 1)
              FTappable(
                onPress: () =>
                    setState(() => _showCandidateList = !_showCandidateList),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacingTokens.level3,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _showCandidateList
                            ? FLucideIcons.chevronUp
                            : FLucideIcons.chevronDown,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '从列表选择其他匹配 (${sorted.length})',
                        style: typography.body.md.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_showCandidateList && sorted.length > 1)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sorted.length,
                  itemBuilder: (_, i) {
                    final r = sorted[i];
                    return FTappable(
                      onPress: () => setState(() => _selectedIndex = i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacingTokens.level2,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedIndex == i
                                  ? FLucideIcons.checkCircle2
                                  : FLucideIcons.circle,
                              color: colors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacingTokens.level3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.name, style: typography.body.md),
                                  Text(
                                    '${r.matchType.name} · ${(r.confidence * 100).toInt()}%',
                                    style: typography.body.sm.copyWith(
                                      color: colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        FButton(
          variant: FButtonVariant.outline,
          onPress: widget.onRetake,
          child: const Text('重新拍照'),
        ),
        FButton(
          onPress: top != null || _selectedIndex != null
              ? () {
                  final result = _selectedIndex != null
                      ? sorted[_selectedIndex!]
                      : top;
                  if (result?.id != null) {
                    Navigator.of(context).pop();
                    context.push('/medicine/reminders/${result!.id}');
                  }
                }
              : null,
          child: const Text('确认，查看详情'),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: typography.body.sm.copyWith(color: colors.mutedForeground),
            ),
          ),
          Expanded(child: Text(value, style: typography.body.md)),
        ],
      ),
    );
  }
}
