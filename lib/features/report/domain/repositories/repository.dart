import 'package:luminous/features/report/domain/entities/dashboard.dart';

abstract interface class ReportRepository {
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query);
  Future<ReportDashboard> get signedOutDashboard;
}
