import 'package:luminous/features/search/domain/entities/medicine_search.dart';

abstract interface class MedicineSearchRepository {
  Future<MedicineSearchDashboard> fetchDashboard();
}
