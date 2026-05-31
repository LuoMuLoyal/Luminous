import 'package:luminous/features/more/domain/entities/more_dashboard.dart';

abstract class MoreRepository {
  Future<MoreDashboard> fetchDashboard();
}
