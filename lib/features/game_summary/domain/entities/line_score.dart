import 'package:equatable/equatable.dart';

/// 점수표(이닝별 득점과 R·H·E·B). 팀 순서는 원정 → 홈.
class LineScore extends Equatable {
  const LineScore({
    required this.inningCount,
    required this.away,
    required this.home,
  });

  /// 표에 그릴 이닝 수. 연장이면 10 이상이다.
  final int inningCount;
  final TeamLineScore away;
  final TeamLineScore home;

  /// 점수가 같으면 null(무승부).
  String? get winnerTeamCode {
    if (home.runs == away.runs) return null;
    return home.runs > away.runs ? home.teamCode : away.teamCode;
  }

  bool get isDraw => home.runs == away.runs;

  /// 1회부터 [inningCount]회까지의 열 제목.
  List<String> get inningHeaders => [
    for (var i = 1; i <= inningCount; i++) '$i',
  ];

  @override
  List<Object?> get props => [inningCount, away, home];
}

class TeamLineScore extends Equatable {
  const TeamLineScore({
    required this.teamCode,
    required this.innings,
    required this.runs,
    required this.hits,
    required this.errors,
    required this.walks,
  });

  final String teamCode;

  /// 이닝별 득점. 하지 않은 이닝(예: 9회말)은 null.
  final List<int?> innings;
  final int runs;
  final int hits;
  final int errors;

  /// 4사구 (점수표의 B).
  final int walks;

  /// 점수표 칸에 쓸 이닝별 문자열. 하지 않은 이닝(이미 이긴 홈 팀의 9회말 등)과
  /// 데이터가 [count]보다 짧은 칸은 표기 없이 비운다 (사용자 결정, KAN-8).
  List<String> inningCells(int count) => [
    for (var i = 0; i < count; i++)
      i < innings.length ? (innings[i]?.toString() ?? '') : '',
  ];

  /// 이닝 번호(1부터)의 득점. 하지 않았거나 데이터가 없으면 0.
  int runsInInning(int inning) {
    final index = inning - 1;
    if (index < 0 || index >= innings.length) return 0;
    return innings[index] ?? 0;
  }

  @override
  List<Object?> get props => [teamCode, innings, runs, hits, errors, walks];
}
