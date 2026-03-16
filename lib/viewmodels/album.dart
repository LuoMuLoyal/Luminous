class IdResult {
  final String id;

  const IdResult({required this.id});

  factory IdResult.fromJson(Map<String, dynamic> json) {
    return IdResult(id: (json['id'] ?? json['_id'] ?? '').toString());
  }

  bool get hasId => id.trim().isNotEmpty;
}

class ScanRecordItem {
  final String id;
  final String thumbBase64;
  final String drugCode;
  final String approvalNo;
  final String productName;
  final int takenAt;

  const ScanRecordItem({
    required this.id,
    required this.thumbBase64,
    required this.drugCode,
    required this.approvalNo,
    required this.productName,
    required this.takenAt,
  });

  factory ScanRecordItem.fromJson(Map<String, dynamic> json) {
    return ScanRecordItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      thumbBase64: (json['thumbBase64'] ?? '').toString(),
      drugCode: (json['drugCode'] ?? '').toString(),
      approvalNo: (json['approvalNo'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      takenAt: int.tryParse((json['takenAt'] ?? '').toString()) ?? 0,
    );
  }

  String get displayName => productName.trim().isEmpty ? '未知药品' : productName.trim();
}

class ScanRecordListResult {
  final List<ScanRecordItem> items;
  final int total;
  final int page;
  final int pageSize;

  const ScanRecordListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ScanRecordListResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) => ScanRecordItem.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <ScanRecordItem>[];

    return ScanRecordListResult(
      items: items,
      total: int.tryParse((json['total'] ?? '').toString()) ?? items.length,
      page: int.tryParse((json['page'] ?? '').toString()) ?? 1,
      pageSize: int.tryParse((json['pageSize'] ?? '').toString()) ?? 20,
    );
  }

  bool get hasMore => page * pageSize < total;
}

