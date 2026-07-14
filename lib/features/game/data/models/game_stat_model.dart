import '../../domain/entities/game_stat.dart';
import '../../domain/entities/player_stat_type.dart';

final class GameStatModel extends GameStat {
  const GameStatModel({
    required super.id,
    required super.gameId,
    required super.teamCode,
    required super.playerName,
    required super.playerNo,
    required super.statType,
    required super.atBats,
    required super.hits,
    required super.doubles,
    required super.triples,
    required super.homeRuns,
    required super.rbi,
    required super.runs,
    required super.walks,
    required super.strikeouts,
    required super.stolenBases,
    required super.battingAverage,
    required super.inningsPitched,
    required super.hitsAllowed,
    required super.earnedRuns,
    required super.strikeoutsPitched,
    required super.walksAllowed,
    required super.homeRunsAllowed,
    required super.win,
    required super.loss,
    required super.save,
    required super.hold,
    required super.era,
  });

  factory GameStatModel.fromJson(Map<String, dynamic> json) {
    return GameStatModel(
      id: json['id'] as int,
      gameId: json['gameId'] as String,
      teamCode: json['teamCode'] as String,
      playerName: json['playerName'] as String,
      playerNo: json['playerNo'] as String?,
      statType: _statTypeFromJson(json['statType'] as String),
      atBats: json['atBats'] as int?,
      hits: json['hits'] as int?,
      doubles: json['doubles'] as int?,
      triples: json['triples'] as int?,
      homeRuns: json['homeRuns'] as int?,
      rbi: json['rbi'] as int?,
      runs: json['runs'] as int?,
      walks: json['walks'] as int?,
      strikeouts: json['strikeouts'] as int?,
      stolenBases: json['stolenBases'] as int?,
      battingAverage: json['battingAverage'] as String?,
      inningsPitched: json['inningsPitched'] as String?,
      hitsAllowed: json['hitsAllowed'] as int?,
      earnedRuns: json['earnedRuns'] as int?,
      strikeoutsPitched: json['strikeoutsPitched'] as int?,
      walksAllowed: json['walksAllowed'] as int?,
      homeRunsAllowed: json['homeRunsAllowed'] as int?,
      win: json['win'] as bool,
      loss: json['loss'] as bool,
      save: json['save'] as bool,
      hold: json['hold'] as bool,
      era: json['era'] as String?,
    );
  }

  static PlayerStatType _statTypeFromJson(String value) {
    return switch (value) {
      'BATTING' => PlayerStatType.batting,
      'PITCHING' => PlayerStatType.pitching,
      _ => throw ArgumentError('Unknown PlayerStatType: $value'),
    };
  }
}
