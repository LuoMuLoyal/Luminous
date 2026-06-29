import 'dart:io';

import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final top = _topResult;
    final sorted = _sortedResults;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.imagePath),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('识别结果', style: theme.textTheme.titleMedium),
                        Text(
                          '来源: ${widget.methodLabel}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColorTokens.cyanDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.lg),

              if (top != null) ...[
                // Top result card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('药品', top.name),
                      if (top.approvalNumber != null)
                        _infoRow('批准文号', top.approvalNumber!),
                      const SizedBox(height: AppSpacingTokens.xs),
                      Text(
                        '置信度: ${(top.confidence * 100).toInt()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColorTokens.cyanDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text('未能识别到药品信息', style: theme.textTheme.bodyLarge),
              ],

              const SizedBox(height: AppSpacingTokens.md),

              // Candidate list expander
              if (sorted.length > 1)
                InkWell(
                  onTap: () =>
                      setState(() => _showCandidateList = !_showCandidateList),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacingTokens.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showCandidateList
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '从列表选择其他匹配 (${sorted.length})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
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
                      return ListTile(
                        leading: Icon(
                          _selectedIndex == i
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(r.name),
                        subtitle: Text(
                          '${r.matchType.name} · ${(r.confidence * 100).toInt()}%',
                        ),
                        onTap: () => setState(() => _selectedIndex = i),
                        dense: true,
                      );
                    },
                  ),
                ),

              const SizedBox(height: AppSpacingTokens.lg),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onRetake,
                      child: const Text('重新拍照'),
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: top != null || _selectedIndex != null
                          ? () {
                              final result = _selectedIndex != null
                                  ? sorted[_selectedIndex!]
                                  : top;
                              if (result?.id != null) {
                                Navigator.pop(context);
                                context.push(
                                  '/medicine/reminders/${result!.id}',
                                );
                              }
                            }
                          : null,
                      child: const Text('确认，查看详情'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
