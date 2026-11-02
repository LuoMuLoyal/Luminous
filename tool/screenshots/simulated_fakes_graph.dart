import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';
import 'package:luminous/features/medicine/domain/repositories/relations.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 关系图端点的模拟实现，供截图生成器使用。
///
/// ## 数据为什么是这三味药
///
/// `simulated_fakes_shell_b.dart` 的当前用药已改成 DrugBank 来源
/// （氨氯地平 `DB00381` / 阿司匹林 `DB00945` / 二甲双胍 `DB00331`），
/// 否则图组件拿不到 `DB\d{5}` 入参，只会渲染「至少需要 2 种可识别的药」。
///
/// 条目内容按真实药理形态书写（CYP3A4 底物、PTGS1 靶点、ABCB1 转运），
/// 但**不是**针对特定患者的临床结论——这些是截图用的一次性演示数据。
class SimulatedMedicineRelationsRepository
    implements MedicineRelationsRepository {
  const SimulatedMedicineRelationsRepository();

  static const _ok = GraphQueryStatus.ok;

  @override
  Future<Either<LucentFailure, GraphQueryResult<MechanismPath>>>
  mechanismPaths(List<String> drugbankIds) async {
    return const Right(
      GraphQueryResult<MechanismPath>(
        status: _ok,
        items: [
          MechanismPath(
            enzymeGene: 'CYP3A4',
            enzymeName: '细胞色素 P450 3A4',
            otherDrugId: 'DB00945',
            otherDrugName: '阿司匹林肠溶片',
            relation: 'INDUCES',
          ),
          MechanismPath(
            enzymeGene: 'CYP2C9',
            enzymeName: '细胞色素 P450 2C9',
            otherDrugId: 'DB00945',
            otherDrugName: '阿司匹林肠溶片',
            relation: 'INHIBITS',
          ),
          MechanismPath(
            enzymeGene: 'OCT2',
            enzymeName: '有机阳离子转运体 2',
            otherDrugId: 'DB00331',
            otherDrugName: '盐酸二甲双胍片',
            relation: 'INHIBITS',
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<LucentFailure, GraphQueryResult<SharedTarget>>>
  sharedTargets(List<String> drugbankIds) async {
    return const Right(
      GraphQueryResult<SharedTarget>(
        status: _ok,
        items: [
          SharedTarget(
            targetGene: 'PTGS1',
            targetName: '前列腺素内过氧化物合酶 1',
            drugCount: 2,
            drugIds: ['DB00945', 'DB00381'],
            drugNames: ['阿司匹林肠溶片', '苯磺酸氨氯地平片'],
          ),
          SharedTarget(
            targetGene: 'CACNA1C',
            targetName: 'L 型钙通道 α1C 亚基',
            drugCount: 2,
            drugIds: ['DB00381', 'DB00331'],
            drugNames: ['苯磺酸氨氯地平片', '盐酸二甲双胍片'],
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<LucentFailure, GraphQueryResult<CascadePath>>> cascadePaths(
    String drugbankId,
  ) async {
    return const Right(
      GraphQueryResult<CascadePath>(
        status: _ok,
        items: [
          CascadePath(
            startDrug: '苯磺酸氨氯地平片',
            enzymeOne: 'CYP3A4',
            middleDrug: '阿司匹林肠溶片',
            enzymeTwo: 'CYP2C9',
            endDrug: '盐酸二甲双胍片',
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<LucentFailure, GraphQueryResult<SubstituteCandidate>>>
  substituteCandidates({
    required String drugbankId,
    required String enzymeGene,
  }) async {
    return const Right(
      GraphQueryResult<SubstituteCandidate>(
        status: _ok,
        items: [
          SubstituteCandidate(
            drugbankId: 'DB01082',
            name: '氯沙坦钾片',
            sharedTarget: 'AGTR1',
          ),
          SubstituteCandidate(
            drugbankId: 'DB00635',
            name: '缬沙坦胶囊',
            sharedTarget: 'AGTR1',
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<LucentFailure, GraphQueryResult<DrugAction>>> drugActions(
    String drugbankId,
  ) async {
    return const Right(
      GraphQueryResult<DrugAction>(
        status: _ok,
        items: [
          DrugAction(
            targetGene: 'CACNA1C',
            targetName: 'L 型钙通道 α1C 亚基',
            relation: 'INHIBITS',
            actions: ['阻滞剂'],
          ),
          DrugAction(
            targetGene: 'PTGS1',
            targetName: '前列腺素内过氧化物合酶 1',
            relation: 'INHIBITS',
            actions: ['不可逆抑制'],
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<LucentFailure, GraphQueryResult<ShortestRoute>>> shortestRoutes({
    required String fromDrugbankId,
    required String toDrugbankId,
  }) async {
    return const Right(
      GraphQueryResult<ShortestRoute>(
        status: _ok,
        items: [
          ShortestRoute(
            stepCount: 2,
            pathNodes: ['苯磺酸氨氯地平片', 'CYP3A4', '阿司匹林肠溶片'],
            pathRelations: ['SUBSTRATE_OF', 'INDUCES'],
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<LucentFailure, GraphQueryResult<TargetDrug>>> targetDrugs(
    String geneName,
  ) async {
    return const Right(
      GraphQueryResult<TargetDrug>(
        status: _ok,
        items: [
          TargetDrug(
            drugbankId: 'DB00945',
            name: '阿司匹林肠溶片',
            relation: 'INHIBITS',
          ),
          TargetDrug(
            drugbankId: 'DB00381',
            name: '苯磺酸氨氯地平片',
            relation: 'ACTS_ON',
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<LucentFailure, GraphQueryResult<TransportRoute>>>
  transportRoutes(String drugbankId) async {
    return const Right(
      GraphQueryResult<TransportRoute>(
        status: _ok,
        items: [
          TransportRoute(
            transporterGene: 'ABCB1',
            transporterName: 'P-糖蛋白',
            inverted: false,
          ),
          TransportRoute(
            transporterGene: 'SLC22A2',
            transporterName: '有机阳离子转运体 2',
            inverted: true,
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<LucentFailure, GraphQueryResult<EnzymeDuel>>> enzymeDuels(
    List<String> drugbankIds,
  ) async {
    return const Right(
      GraphQueryResult<EnzymeDuel>(
        status: _ok,
        items: [
          EnzymeDuel(
            enzymeGene: 'CYP3A4',
            inducerDrug: '阿司匹林肠溶片',
            inhibitedSubstrate: '苯磺酸氨氯地平片',
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<LucentFailure, MedicationOverview>> medicationOverview() async {
    return const Right(
      MedicationOverview(
        totalMedicines: 3,
        resolvableMedicines: 3,
        duplicates: [
          DuplicateIngredientGroup(
            ingredientKey: '钙通道阻滞剂',
            entryIds: ['cm_amlodipine_2026', 'cm_amlodipine_prev'],
            displayNames: ['苯磺酸氨氯地平片', '氨氯地平片（旧）'],
            severity: DuplicateSeverity.medium,
          ),
        ],
        sourceOverlaps: [
          SourceOverlap(
            source: 'scn_event_8821',
            medicineCount: 2,
            displayNames: ['阿司匹林肠溶片', '苯磺酸氨氯地平片'],
          ),
          SourceOverlap(
            source: 'unattributed',
            medicineCount: 1,
            displayNames: ['盐酸二甲双胍片'],
          ),
        ],
      ),
    );
  }
}
