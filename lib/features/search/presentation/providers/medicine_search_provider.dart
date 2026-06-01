import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/search/data/repositories/mock_medicine_search_repository.dart';
import 'package:luminous/features/search/domain/entities/medicine_search.dart';

final medicineSearchProvider = FutureProvider<MedicineSearchDashboard>((ref) {
  return ref.watch(medicineSearchRepositoryProvider).fetchDashboard().timeout(const Duration(seconds: 5), onTimeout: () => throw TimeoutException("请求超时，请检查网络后重试。"));
});
