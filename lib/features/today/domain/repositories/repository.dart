import 'package:luminous/features/today/domain/entities/dashboard.dart';

abstract interface class TodayRepository {
  Future<TodayDashboard> fetchDashboard();
  Future<TodayDashboard> get signedOutDashboard;
}
