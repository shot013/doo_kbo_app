import '../../domain/entities/game_preview.dart';
import 'pitcher_matchup_model.dart';
import 'team_preview_stats_model.dart';

final class GamePreviewModel extends GamePreview {
  const GamePreviewModel({
    required super.gameId,
    required super.homeTeam,
    required super.awayTeam,
    required super.homePitcher,
    required super.awayPitcher,
    required super.scrapedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GamePreviewModel.fromJson(Map<String, dynamic> json) {
    return GamePreviewModel(
      gameId: json['gameId'] as String,
      homeTeam: TeamPreviewStatsModel.homeFromJson(json),
      awayTeam: TeamPreviewStatsModel.awayFromJson(json),
      homePitcher: PitcherMatchupModel.homeFromJson(json),
      awayPitcher: PitcherMatchupModel.awayFromJson(json),
      scrapedAt: DateTime.parse(json['scrapedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
