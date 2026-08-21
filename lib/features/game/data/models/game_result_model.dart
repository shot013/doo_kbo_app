import '../../domain/entities/game_result.dart';
import 'best_performer_model.dart';
import 'pitcher_decision_model.dart';

final class GameResultModel extends GameResult {
  const GameResultModel({
    required super.gameId,
    required super.gameDate,
    required super.stadium,
    required super.homeTeamCode,
    required super.homeTeamName,
    required super.awayTeamCode,
    required super.awayTeamName,
    required super.homeScore,
    required super.awayScore,
    required super.bestPerformer,
    required super.pitchers,
  });

  factory GameResultModel.fromJson(Map<String, dynamic> json) {
    final bestPerformerJson = json['bestPerformer'] as Map<String, dynamic>?;
    final pitchersJson = json['pitchers'] as List<dynamic>;

    return GameResultModel(
      gameId: json['gameId'] as String,
      gameDate: json['gameDate'] as String,
      stadium: json['stadium'] as String?,
      homeTeamCode: json['homeTeamCode'] as String,
      homeTeamName: json['homeTeamName'] as String,
      awayTeamCode: json['awayTeamCode'] as String,
      awayTeamName: json['awayTeamName'] as String,
      homeScore: json['homeScore'] as int,
      awayScore: json['awayScore'] as int,
      bestPerformer: bestPerformerJson == null
          ? null
          : BestPerformerModel.fromJson(bestPerformerJson),
      pitchers: pitchersJson
          .map(
            (pitcher) =>
                PitcherDecisionModel.fromJson(pitcher as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
