import 'package:luminous/features/report/domain/entities/report_dashboard.dart';

abstract interface class ReportRepository {
  Future<ReportDashboard> fetchDashboard();
}
