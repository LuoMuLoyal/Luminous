class StepCapability {
  const StepCapability({required this.available, this.reason, this.message});

  final bool available;
  final String? reason;
  final String? message;
}

class NativeStepSample {
  const NativeStepSample({
    required this.count,
    required this.startMs,
    required this.endMs,
    required this.source,
  });

  final int count;
  final int startMs;
  final int endMs;
  final String source;
}
