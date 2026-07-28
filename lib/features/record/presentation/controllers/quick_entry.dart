import 'package:luminous/features/record/domain/entities/dashboard.dart';

class QuickEntryActionContext {
  const QuickEntryActionContext({required this.action});

  final RecordQuickAction action;
}

typedef QuickEntryExecute =
    Future<void> Function(QuickEntryActionContext context);

class QuickEntryController {
  const QuickEntryController({required this.execute});

  final QuickEntryExecute execute;

  Future<void> handleTap(QuickEntryActionContext context) {
    return execute(context);
  }
}
