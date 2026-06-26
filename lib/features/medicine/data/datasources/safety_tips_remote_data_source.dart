import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_safety_tip.dart';

class SafetyTipsRemoteDataSource {
  const SafetyTipsRemoteDataSource({required this.api});

  final MedicinesApi api;

  Future<List<MedicineSafetyTip>> fetchTips({List<String>? excludeIds}) async {
    final response = await api.medicinesControllerGetSafetyTipsV1(
      exclude: excludeIds,
    );
    final dtos = response.data ?? const [];
    return dtos
        .map(
          (dto) => MedicineSafetyTip(
            id: dto.id,
            text: dto.text,
            category: dto.category,
          ),
        )
        .toList(growable: false);
  }
}
