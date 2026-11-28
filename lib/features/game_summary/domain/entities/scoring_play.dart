import 'package:equatable/equatable.dart';

import 'inning_half.dart';

/// 득점 장면. 점수가 난 순서대로 온다.
class ScoringPlay extends Equatable {
  const ScoringPlay({
    required this.inning,
    required this.half,
    required this.teamCode,
    required this.description,
    required this.homeScore,
    required this.awayScore,
    required this.isReversal,
    required this.isTying,
  });

  final int inning;
  final InningHalf? half;
  final String teamCode;
  final String description;

  /// 이 득점 뒤의 점수.
  final int homeScore;
  final int awayScore;

  /// 득점으로 리드한 팀이 바뀌었는지.
  final bool isReversal;

  /// 득점으로 동점이 됐는지.
  final bool isTying;

  /// 예: `6회말`
  String get inningText => inningLabel(inning, half);

  /// 예: `정내야 3점 홈런 (역전)`
  String get descriptionText {
    if (isReversal) return '$description (역전)';
    if (isTying) return '$description (동점)';
    return description;
  }

  /// 그 뒤 점수, 홈:원정 순서. 예: `4:3`
  String get scoreText => '$homeScore:$awayScore';

  @override
  List<Object?> get props => [
    inning,
    half,
    teamCode,
    description,
    homeScore,
    awayScore,
    isReversal,
    isTying,
  ];
}
