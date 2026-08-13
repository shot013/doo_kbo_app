import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 즐겨찾기 팀 관리(F6)는 이번 범위 밖이라 영속화하지 않는, 인메모리 토글 상태입니다.
final favoriteTeamsProvider =
    NotifierProvider<FavoriteTeamsNotifier, Set<String>>(
      FavoriteTeamsNotifier.new,
    );

class FavoriteTeamsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String teamCode) {
    final next = {...state};
    if (!next.remove(teamCode)) {
      next.add(teamCode);
    }
    state = next;
  }
}
