import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StatTab { standing, record, team, player }

final statTabProvider = NotifierProvider<StatTabNotifier, StatTab>(
  StatTabNotifier.new,
);

class StatTabNotifier extends Notifier<StatTab> {
  @override
  StatTab build() => StatTab.standing;

  void select(StatTab tab) {
    state = tab;
  }
}
