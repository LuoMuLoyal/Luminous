class MedicineAiSafetyResult {
  final String text;

  const MedicineAiSafetyResult({required this.text});

  factory MedicineAiSafetyResult.fromJson(Map<String, dynamic> json) {
    return MedicineAiSafetyResult(text: (json['text'] ?? '').toString());
  }

  bool get hasText => text.trim().isNotEmpty;
}

