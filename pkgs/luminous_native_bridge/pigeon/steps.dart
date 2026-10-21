import 'package:pigeon/pigeon.dart';

class StepCapability {
  StepCapability({required this.available, this.reason, this.message});

  final bool available;
  final String? reason;
  final String? message;
}

class StepReadRequest {
  StepReadRequest({required this.startMs, required this.endMs});

  final int startMs;
  final int endMs;
}

class NativeStep {
  NativeStep({
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

@HostApi()
abstract class StepHostApi {
  @async
  StepCapability capability();

  @async
  List<NativeStep> read(StepReadRequest request);
}
