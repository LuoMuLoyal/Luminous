import 'dart:math';

/// Result from matching OCR text against medicine database.
class MedicineMatchResult {
  const MedicineMatchResult({
    required this.name,
    this.approvalNumber,
    this.id,
    required this.confidence,
    required this.matchType,
  });

  final String name;
  final String? approvalNumber;
  final String? id;
  final double confidence;
  final MedicineMatchType matchType;
}

enum MedicineMatchType { approvalNumber, barcode, nameFuzzy }

/// Multi-strategy engine for extracting medicine info from OCR text.
class MedicineTextMatcher {
  const MedicineTextMatcher();

  static final _approvalNumberRegex = RegExp(r'国药准字[HZSBJ]\d{8}');
  static final _barcodeRegex = RegExp(r'\b(69\d{11})\b');

  /// Extract candidates from OCR text. Strategies run serially, first hit wins.
  List<MedicineMatchCandidate> extractCandidates(String ocrText) {
    // Strategy 1: Approval number
    final approvalMatch = _approvalNumberRegex.firstMatch(ocrText);
    if (approvalMatch != null) {
      return [
        MedicineMatchCandidate(
          query: approvalMatch.group(0)!,
          matchType: MedicineMatchType.approvalNumber,
          confidence: 1.0,
        ),
      ];
    }

    // Strategy 2: Barcode
    final barcodeMatch = _barcodeRegex.firstMatch(ocrText);
    if (barcodeMatch != null) {
      return [
        MedicineMatchCandidate(
          query: barcodeMatch.group(0)!,
          matchType: MedicineMatchType.barcode,
          confidence: 0.95,
        ),
      ];
    }

    // Strategy 3: Drug name fuzzy — extract longest CJK segments
    final candidates = _extractNameSegments(ocrText);
    return candidates
        .map(
          (name) => MedicineMatchCandidate(
            query: name,
            matchType: MedicineMatchType.nameFuzzy,
            confidence: _nameConfidence(name),
          ),
        )
        .toList();
  }

  List<String> _extractNameSegments(String text) {
    // Extract consecutive CJK characters (2-8 chars) as drug name candidates
    final cjkPattern = RegExp(r'[\u4e00-\u9fff]{2,8}');
    final matches = cjkPattern.allMatches(text);
    // Filter common non-drug words and deduplicate
    final stopWords = {
      '药品',
      '用法',
      '用量',
      '注意',
      '事项',
      '禁忌',
      '不良反应',
      '贮藏',
      '规格',
      '厂商',
      '生产',
      '企业',
      '批准',
      '文号',
      '说明书',
      '包装',
      '本品',
      '一天',
      '每次',
      '每日',
      '一次',
      '两次',
      '三次',
      '毫克',
      '毫升',
      '克',
      '片',
      '粒',
    };
    final seen = <String>{};
    return matches
        .map((m) => m.group(0)!)
        .where((w) => !stopWords.contains(w) && seen.add(w))
        .take(5)
        .toList();
  }

  double _nameConfidence(String name) {
    // Longer names are more likely to be drug names (max at 6 chars)
    return min(name.length / 6.0, 0.85);
  }
}

class MedicineMatchCandidate {
  const MedicineMatchCandidate({
    required this.query,
    required this.matchType,
    required this.confidence,
  });

  final String query;
  final MedicineMatchType matchType;
  final double confidence;
}
