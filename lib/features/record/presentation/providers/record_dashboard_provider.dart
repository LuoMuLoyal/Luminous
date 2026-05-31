import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/record/data/repositories/mock_record_repository.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';

final recordDashboardProvider = FutureProvider<RecordDashboard>((ref) {
  return ref.watch(recordRepositoryProvider).fetchDashboard();
});
