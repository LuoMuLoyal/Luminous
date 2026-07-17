import 'package:luminous/features/mine/domain/entities/dashboard.dart';

abstract interface class MineRepository {
  Future<MineDashboard> fetchDashboard();
  Future<MineDashboard> get signedOutDashboard;
}
