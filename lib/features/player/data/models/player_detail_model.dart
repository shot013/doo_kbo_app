import '../../../../core/constants/player_position.dart';
import '../../domain/entities/player_detail.dart';
import '../../domain/entities/player_stat_line.dart';
import '../../domain/entities/player_vs_batter_stat.dart';
import '../../domain/entities/player_vs_pitcher_stat.dart';
import '../../domain/entities/player_vs_team_stat.dart';

final class PlayerDetailModel extends PlayerDetail {
  const PlayerDetailModel({
    required super.id,
    required super.name,
    required super.teamCode,
    required super.teamName,
    required super.position,
    required super.backNumber,
    required super.statLines,
    required super.vsTeamStats,
    required super.vsPitcherStats,
    required super.vsBatterStats,
  });

  factory PlayerDetailModel.fromJson(Map<String, dynamic> json) {
    final statLinesJson = json['statLines'] as List<dynamic>? ?? const [];
    final vsTeamStatsJson = json['vsTeamStats'] as List<dynamic>? ?? const [];
    final vsPitcherStatsJson =
        json['vsPitcherStats'] as List<dynamic>? ?? const [];
    final vsBatterStatsJson =
        json['vsBatterStats'] as List<dynamic>? ?? const [];
    return PlayerDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      teamCode: json['teamCode'] as String,
      teamName: json['teamName'] as String,
      position: PlayerPosition.values.byName(json['position'] as String),
      backNumber: json['backNumber'] as int,
      statLines: statLinesJson
          .map(
            (entry) => PlayerStatLine(
              label: (entry as Map<String, dynamic>)['label'] as String,
              value: entry['value'] as String,
            ),
          )
          .toList(),
      vsTeamStats: vsTeamStatsJson
          .map(
            (entry) => PlayerVsTeamStat(
              teamCode: (entry as Map<String, dynamic>)['teamCode'] as String,
              teamName: entry['teamName'] as String,
              games: entry['games'] as int,
              avg: entry['avg'] as String,
            ),
          )
          .toList(),
      vsPitcherStats: vsPitcherStatsJson
          .map(
            (entry) => PlayerVsPitcherStat(
              pitcherId: (entry as Map<String, dynamic>)['pitcherId'] as int,
              pitcherName: entry['pitcherName'] as String,
              pitcherTeamCode: entry['pitcherTeamCode'] as String,
              atBats: entry['atBats'] as int,
              hits: entry['hits'] as int,
              avg: entry['avg'] as String,
            ),
          )
          .toList(),
      vsBatterStats: vsBatterStatsJson
          .map(
            (entry) => PlayerVsBatterStat(
              batterId: (entry as Map<String, dynamic>)['batterId'] as int,
              batterName: entry['batterName'] as String,
              batterTeamCode: entry['batterTeamCode'] as String,
              atBats: entry['atBats'] as int,
              strikeouts: entry['strikeouts'] as int,
              strikeoutRate: entry['strikeoutRate'] as String,
            ),
          )
          .toList(),
    );
  }
}
