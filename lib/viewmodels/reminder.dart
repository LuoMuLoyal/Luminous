class ReminderPlan {
  final String id;
  final String userId;
  final String time;
  final String drugCode;
  final String approvalNo;
  final String productName;
  final String subtitle;
  final bool enabled;
  final String repeatRule;
  final String method;

  const ReminderPlan({
    required this.id,
    required this.userId,
    required this.time,
    required this.drugCode,
    required this.approvalNo,
    required this.productName,
    required this.subtitle,
    required this.enabled,
    required this.repeatRule,
    required this.method,
  });

  factory ReminderPlan.fromJson(Map<String, dynamic> json) {
    return ReminderPlan(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      drugCode: (json['drugCode'] ?? '').toString(),
      approvalNo: (json['approvalNo'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      enabled: json['enabled'] != false,
      repeatRule: (json['repeatRule'] ?? 'daily').toString(),
      method: (json['method'] ?? 'notification').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'time': time,
      'drugCode': drugCode,
      'approvalNo': approvalNo,
      'productName': productName,
      'subtitle': subtitle,
      'enabled': enabled,
      'repeatRule': repeatRule,
      'method': method,
    };
  }

  bool get hasId => id.trim().isNotEmpty;

  String get displayTitle {
    final t = time.trim();
    final n = productName.trim().isEmpty ? '未知药品' : productName.trim();
    return t.isEmpty ? n : '$t $n';
  }
}

class ReminderListResult {
  final List<ReminderPlan> items;

  const ReminderListResult({required this.items});

  factory ReminderListResult.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => ReminderPlan.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <ReminderPlan>[];
    return ReminderListResult(items: items);
  }
}

