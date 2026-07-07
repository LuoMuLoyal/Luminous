import 'package:luminous/features/mine/domain/entities/dashboard.dart';

abstract class MineRepository {
  Future<MineDashboard> fetchDashboard();
  Future<MineDashboard> get signedOutDashboard;
}
