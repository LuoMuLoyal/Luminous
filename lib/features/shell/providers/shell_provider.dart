import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shell_provider.freezed.dart';

@freezed
abstract class ShellState with _$ShellState {
  const factory ShellState({@Default(0) int currentIndex}) = _ShellState;
}

class ShellNotifier extends Notifier<ShellState> {
  @override
  ShellState build() => const ShellState();

  void selectTab(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

final shellProvider = NotifierProvider<ShellNotifier, ShellState>(
  ShellNotifier.new,
);
