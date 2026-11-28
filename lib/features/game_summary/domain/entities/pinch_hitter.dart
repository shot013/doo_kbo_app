import 'package:equatable/equatable.dart';

import 'inning_half.dart';

/// 팀별 대타 성적 합계.
class PinchHitterSummary extends Equatable {
  const PinchHitterSummary({
    required this.teamCode,
    required this.count,
    required this.atBats,
    required this.hits,
    required this.rbi,
  });

  final String teamCode;
  final int count;
  final int atBats;
  final int hits;
  final int rbi;

  /// 예: `대타 2명`
  String get countLabel => '대타 $count명';

  /// 예: `1타수 1안타 1타점`, `2타수 무안타`
  String get lineLabel {
    final parts = <String>[
      if (atBats == 0) '타수 없음' else '$atBats타수',
      if (atBats > 0) hits == 0 ? '무안타' : '$hits안타',
      if (rbi > 0) '$rbi타점',
    ];
    return parts.join(' ');
  }

  @override
  List<Object?> get props => [teamCode, count, atBats, hits, rbi];
}

/// 대타 한 번의 기용. 기용 순서대로 온다.
class PinchHitterAppearance extends Equatable {
  const PinchHitterAppearance({
    required this.inning,
    required this.half,
    required this.teamCode,
    required this.playerId,
    required this.playerName,
    required this.replacedPlayerId,
    required this.replacedPlayerName,
    required this.pitcherId,
    required this.pitcherName,
    required this.resultText,
    required this.isHit,
    required this.rbi,
  });

  final int inning;
  final InningHalf? half;
  final String teamCode;
  final int? playerId;
  final String playerName;
  final int? replacedPlayerId;
  final String? replacedPlayerName;

  /// 타석에 서기 전에 이닝이 끝나면 null.
  final int? pitcherId;
  final String? pitcherName;
  final String? resultText;
  final bool isHit;

  /// 그 타석의 타점. API가 점수를 몰라 null로 주면 0으로 받아 타점을 표시하지
  /// 않는다 (KAN-8 v2).
  final int rbi;

  /// 예: `8회말`
  String get inningText => inningLabel(inning, half);

  /// 예: `대타 표중견`
  String get title => '대타 $playerName';

  /// 예: `노우익 대신 · vs 홍좌완`
  String get matchupText {
    final parts = <String>[
      if (replacedPlayerName != null) '$replacedPlayerName 대신',
      if (pitcherName != null) 'vs $pitcherName',
    ];
    return parts.join(' · ');
  }

  /// 예: `2루타 · 1타점`, `삼진`. 타석에 서기 전에 이닝이 끝났으면 null
  /// (정책서 5.8: 결과 칸을 비운다).
  String? get resultLabel {
    final result = resultText;
    if (result == null) return null;
    return rbi > 0 ? '$result · $rbi타점' : result;
  }

  /// 안타나 타점이 있으면 강조한다.
  bool get isGoodResult => isHit || rbi > 0;

  @override
  List<Object?> get props => [
    inning,
    half,
    teamCode,
    playerId,
    playerName,
    replacedPlayerId,
    replacedPlayerName,
    pitcherId,
    pitcherName,
    resultText,
    isHit,
    rbi,
  ];
}
