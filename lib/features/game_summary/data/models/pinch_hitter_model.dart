import '../../domain/entities/pinch_hitter.dart';
import 'summary_json_codec.dart';

final class PinchHitterSummaryModel extends PinchHitterSummary {
  const PinchHitterSummaryModel({
    required super.teamCode,
    required super.count,
    required super.atBats,
    required super.hits,
    required super.rbi,
  });

  factory PinchHitterSummaryModel.fromJson(Map<String, dynamic> json) {
    return PinchHitterSummaryModel(
      teamCode: json['teamCode'] as String,
      count: json['count'] as int,
      atBats: json['atBats'] as int,
      hits: json['hits'] as int,
      rbi: json['rbi'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'teamCode': teamCode,
    'count': count,
    'atBats': atBats,
    'hits': hits,
    'rbi': rbi,
  };
}

final class PinchHitterAppearanceModel extends PinchHitterAppearance {
  const PinchHitterAppearanceModel({
    required super.inning,
    required super.half,
    required super.teamCode,
    required super.playerId,
    required super.playerName,
    required super.replacedPlayerId,
    required super.replacedPlayerName,
    required super.pitcherId,
    required super.pitcherName,
    required super.resultText,
    required super.isHit,
    required super.rbi,
  });

  factory PinchHitterAppearanceModel.fromJson(Map<String, dynamic> json) {
    return PinchHitterAppearanceModel(
      inning: json['inning'] as int,
      half: inningHalfFromJson(json['half']),
      teamCode: json['teamCode'] as String,
      playerId: json['playerId'] as int?,
      playerName: json['playerName'] as String,
      replacedPlayerId: json['replacedPlayerId'] as int?,
      replacedPlayerName: json['replacedPlayerName'] as String?,
      pitcherId: json['pitcherId'] as int?,
      pitcherName: json['pitcherName'] as String?,
      resultText: json['resultText'] as String?,
      isHit: json['isHit'] as bool? ?? false,
      rbi: json['rbi'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'inning': inning,
    'half': inningHalfToJson(half),
    'teamCode': teamCode,
    'playerId': playerId,
    'playerName': playerName,
    'replacedPlayerId': replacedPlayerId,
    'replacedPlayerName': replacedPlayerName,
    'pitcherId': pitcherId,
    'pitcherName': pitcherName,
    'resultText': resultText,
    'isHit': isHit,
    'rbi': rbi,
  };
}
