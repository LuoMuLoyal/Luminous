class CheckinCreateResult {
  final String id;

  const CheckinCreateResult({required this.id});

  factory CheckinCreateResult.fromJson(Map<String, dynamic> json) {
    return CheckinCreateResult(id: (json['id'] ?? json['_id'] ?? '').toString());
  }

  bool get hasId => id.trim().isNotEmpty;
}

