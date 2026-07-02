/// Abstraction over [DateTime.now()] to make time-based logic testable.
///
/// TODO: inject [Clock] throughout the codebase instead of calling
/// [DateTime.now()] directly in business logic.
abstract interface class Clock {
  const Clock();

  DateTime now();
}

/// Production implementation that delegates to [DateTime.now()].
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
