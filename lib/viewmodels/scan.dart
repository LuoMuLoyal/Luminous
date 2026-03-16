class ScanCandidate {
  final String drugCode;
  final String approvalNo;
  final String productName;
  final String dosageForm;
  final String specification;
  final String manufacturer;
  final double score;

  const ScanCandidate({
    required this.drugCode,
    required this.approvalNo,
    required this.productName,
    required this.dosageForm,
    required this.specification,
    required this.manufacturer,
    required this.score,
  });

  factory ScanCandidate.fromJson(Map<String, dynamic> json) {
    return ScanCandidate(
      drugCode: (json['drugCode'] ?? '').toString(),
      approvalNo: (json['approvalNo'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      dosageForm: (json['dosageForm'] ?? '').toString(),
      specification: (json['specification'] ?? '').toString(),
      manufacturer: (json['manufacturer'] ?? '').toString(),
      score: _parseDouble(json['score']),
    );
  }

  bool get hasIdentity => drugCode.trim().isNotEmpty || approvalNo.trim().isNotEmpty;

  String get displayName => productName.trim().isEmpty ? '未知药品' : productName.trim();

  String get displaySubtitle {
    final parts = <String>[
      if (dosageForm.trim().isNotEmpty) dosageForm.trim(),
      if (specification.trim().isNotEmpty) specification.trim(),
    ];
    return parts.isEmpty ? '暂无规格信息' : parts.join(' · ');
  }
}

class MedicineScanResult {
  final List<ScanCandidate> candidates;
  final String thumbBase64;

  const MedicineScanResult({
    required this.candidates,
    required this.thumbBase64,
  });

  factory MedicineScanResult.fromJson(Map<String, dynamic> json) {
    final raw = json['candidates'];
    final candidates = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => ScanCandidate.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <ScanCandidate>[];

    return MedicineScanResult(
      candidates: candidates,
      thumbBase64: (json['thumbBase64'] ?? '').toString(),
    );
  }
}

double _parseDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse((value ?? '').toString()) ?? 0.0;
}

