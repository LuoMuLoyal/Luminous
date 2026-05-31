import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';

abstract interface class MedicineWorkspaceRepository {
  Future<MedicineWorkspace> fetchWorkspace();
}
