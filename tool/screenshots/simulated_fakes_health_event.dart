import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 健康事件（「健康观察」）的模拟实现，供截图生成器使用。
///
/// 今日页的「健康观察」区块读 `activeHealthEventProvider`；不接这个仓储时它
/// 会走真实网络并在测试环境失败，整块渲染成「健康观察暂不可用，请重试」——
/// 截出来是错误态，不是这个页面的正常样子。
///
/// 演示数据与 `simulated_fakes_shell_b.dart` 的用药集合一致（氨氯地平 /
/// 阿司匹林 / 二甲双胍），这样「关联用药」在页面上说得通。
class SimulatedHealthEventRepository implements HealthEventRepository {
  const SimulatedHealthEventRepository();

  static const _active = HealthEvent(
    id: 'hev-afternoon-dizziness',
    title: '近一周午后头晕',
    status: HealthEventStatus.active,
    startedAt: '2026-06-12T02:10:00.000Z',
    currentMedicineIds: [
      'cm_amlodipine_2026',
      'cm_aspirin_2026',
      'cm_metformin_2026',
    ],
    coverage: HealthEventCoverage(
      checkInCount: 6,
      firstCheckInDate: '2026-06-13',
      lastCheckInDate: '2026-06-18',
    ),
  );

  @override
  TaskEither<LucentFailure, HealthEvent?> fetchActive() =>
      TaskEither.right(_active);

  @override
  TaskEither<LucentFailure, HealthEvent?> fetchById(String eventId) =>
      TaskEither.right(_active);

  @override
  TaskEither<LucentFailure, List<HealthEvent>> fetchHistory() =>
      TaskEither.right(const [
        _active,
        HealthEvent(
          id: 'hev-metformin-gi',
          title: '二甲双胍餐后胃部不适',
          status: HealthEventStatus.ended,
          startedAt: '2026-05-20T02:00:00.000Z',
          currentMedicineIds: ['cm_metformin_2026'],
          coverage: HealthEventCoverage(
            checkInCount: 4,
            firstCheckInDate: '2026-05-21',
            lastCheckInDate: '2026-05-26',
          ),
        ),
      ]);

  @override
  TaskEither<LucentFailure, HealthEvent> create({
    required String title,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
  }) => TaskEither.right(_active);

  @override
  TaskEither<LucentFailure, HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) => TaskEither.right(_active);

  @override
  TaskEither<LucentFailure, HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) => TaskEither.right(_active);
}
