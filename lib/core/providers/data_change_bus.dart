import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_change_bus.g.dart';

/// Domain topics for cross-feature data invalidation.
///
/// When a feature mutates data that other features depend on, it emits a
/// topic via [DataChangeBusNotifier.emit]. Dashboard/workspace providers
/// that need to refresh on cross-feature changes watch the bus's version
/// for relevant topics, causing automatic rebuilds.
///
/// This replaces direct `ref.invalidate(otherFeatureProvider)` calls that
/// created presentation→presentation coupling between features.
///
/// ## Topics
///
/// | Topic | Emitted by | Watched by |
/// |---|---|---|
/// | [dailyRecords] | record (create/update/delete/NLP) | recordDashboard, todayDashboard, reportDashboard |
/// | [healthContext] | mine (profile/allergy/condition edits), settings (preference sync) | healthContextSnapshot, mineDashboard |
/// | [currentMedicines] | mine (current medicine add/remove), search (add to current medicines) | medicineWorkspace, todayDashboard, healthContextSnapshot |
/// | [doseLogs] | medicine (mark dose) | medicineWorkspace, todayDashboard |
/// | [medicineReminders] | medicine (reminder create/update/delete) | medicineWorkspace, todayDashboard |
/// | [userSettings] | settings (water target, AI toggles) | todayDashboard |
abstract final class DataChangeTopic {
  DataChangeTopic._();

  /// Daily records were created/updated/deleted.
  static const dailyRecords = 'dailyRecords';

  /// Health context data changed (profile, allergies, conditions).
  static const healthContext = 'healthContext';

  /// Current medicines list changed (add/remove/update).
  static const currentMedicines = 'currentMedicines';

  /// Medicine dose logs changed (mark/create).
  static const doseLogs = 'doseLogs';

  /// Medicine reminders changed (create/update/delete).
  static const medicineReminders = 'medicineReminders';

  /// User settings changed (water target, AI toggles, etc.).
  static const userSettings = 'userSettings';
}

/// A lightweight event bus for cross-feature data invalidation.
///
/// Features that mutate data call [emit] to broadcast a change topic.
/// Dashboard/workspace providers call [dataChangeVersion] to watch a topic's
/// version — when it changes, Riverpod automatically rebuilds the watching
/// provider.
///
/// Usage (emitting):
/// ```dart
/// ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.dailyRecords);
/// ```
///
/// Usage (watching):
/// ```dart
/// @Riverpod(keepAlive: true)
/// Future<Dashboard> dashboard(Ref ref) async {
///   ref.watch(dataChangeVersionProvider(DataChangeTopic.dailyRecords));
///   // ... fetch data
/// }
/// ```
@Riverpod(keepAlive: true)
class DataChangeBus extends _$DataChangeBus {
  @override
  Map<String, int> build() => {};

  /// Increment the version counter for [topic].
  ///
  /// Any provider watching [dataChangeVersionProvider] for this topic
  /// will be rebuilt on the next frame.
  void emit(String topic) {
    state = {...state, topic: (state[topic] ?? 0) + 1};
  }
}

/// Family provider that returns the current version counter for [topic].
///
/// Watch this inside a dashboard/workspace provider to trigger automatic
/// rebuilds when the corresponding data changes:
///
/// ```dart
/// ref.watch(dataChangeVersionProvider(DataChangeTopic.dailyRecords));
/// ```
@riverpod
int dataChangeVersion(Ref ref, String topic) {
  final bus = ref.watch(dataChangeBusProvider);
  return bus[topic] ?? 0;
}
