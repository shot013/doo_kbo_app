import 'package:equatable/equatable.dart';

import 'player_stat_type.dart';

class GameStat extends Equatable {
  const GameStat({
    required this.id,
    required this.gameId,
    required this.teamCode,
    required this.playerName,
    required this.playerNo,
    required this.statType,
    required this.atBats,
    required this.hits,
    required this.doubles,
    required this.triples,
    required this.homeRuns,
    required this.rbi,
    required this.runs,
    required this.walks,
    required this.strikeouts,
    required this.stolenBases,
    required this.battingAverage,
    required this.inningsPitched,
    required this.hitsAllowed,
    required this.earnedRuns,
    required this.strikeoutsPitched,
    required this.walksAllowed,
    required this.homeRunsAllowed,
    required this.win,
    required this.loss,
    required this.save,
    required this.hold,
    required this.era,
  });

  final int id;
  final String gameId;
  final String teamCode;
  final String playerName;
  final String? playerNo;
  final PlayerStatType statType;

  // batting
  final int? atBats;
  final int? hits;
  final int? doubles;
  final int? triples;
  final int? homeRuns;
  final int? rbi;
  final int? runs;
  final int? walks;
  final int? strikeouts;
  final int? stolenBases;
  final String? battingAverage;

  // pitching
  final String? inningsPitched;
  final int? hitsAllowed;
  final int? earnedRuns;
  final int? strikeoutsPitched;
  final int? walksAllowed;
  final int? homeRunsAllowed;
  final bool win;
  final bool loss;
  final bool save;
  final bool hold;
  final String? era;

  @override
  List<Object?> get props => [
    id,
    gameId,
    teamCode,
    playerName,
    playerNo,
    statType,
    atBats,
    hits,
    doubles,
    triples,
    homeRuns,
    rbi,
    runs,
    walks,
    strikeouts,
    stolenBases,
    battingAverage,
    inningsPitched,
    hitsAllowed,
    earnedRuns,
    strikeoutsPitched,
    walksAllowed,
    homeRunsAllowed,
    win,
    loss,
    save,
    hold,
    era,
  ];
}
