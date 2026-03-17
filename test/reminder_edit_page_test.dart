import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/pages/Reminders/reminder_edit.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/viewmodels/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    final controller = Get.put(UserController(), permanent: true);
    await controller.init();
  });

  testWidgets('editing product name clears stale medicine identity', (
    tester,
  ) async {
    const initialPlan = ReminderPlan(
      id: 'reminder-1',
      userId: 'user-1',
      time: '08:00',
      drugCode: 'drug-001',
      approvalNo: 'H123456',
      productName: '阿莫西林',
      subtitle: '早餐后服用 1 粒',
      enabled: true,
      repeatRule: 'daily',
      method: 'notification',
    );

    await tester.pumpWidget(
      const MaterialApp(home: ReminderEditPage(initial: initialPlan)),
    );

    expect(find.textContaining('drugCode: drug-001'), findsOneWidget);
    expect(find.textContaining('approvalNo: H123456'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '新的药品名称');
    await tester.pump();

    expect(find.text('可从“我的药品/搜索库”选择'), findsOneWidget);
    expect(find.textContaining('drugCode: drug-001'), findsNothing);
    expect(find.textContaining('approvalNo: H123456'), findsNothing);
  });
}
