import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';

abstract class MineRepository {
  Future<MineDashboard> fetchDashboard();
}
