import 'package:luminous/features/medicine/domain/entities/workspace.dart';

abstract interface class MedicineWorkspaceRepository {
  Future<MedicineWorkspace> fetchWorkspace();
  Future<MedicineWorkspace> get signedOutWorkspace;
}
