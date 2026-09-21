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

  /// go_router의 `extra`로 [GameResult] 인스턴스를 넘기면, Flutter DevTools/
  /// 라우터 인스펙터가 라우트 상태를 표시하려고 이 값을 직렬화를 시도한다.
  /// `toJson()`이 없으면 `NoSuchMethodError`가 던져지는데, 릴리즈 빌드는 그걸
  /// 지켜보는 디버거가 없어 무시되지만 IDE 디버거가 "예외 발생 시 중단"으로
  /// 붙어있으면 그 순간 전체 isolate가 멈춰 ANR로 이어진다.
  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'gameDate': gameDate,
    'stadium': stadium,
    'homeTeamCode': homeTeamCode,
    'homeTeamName': homeTeamName,
    'awayTeamCode': awayTeamCode,
    'awayTeamName': awayTeamName,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'bestPerformer': (bestPerformer as BestPerformerModel?)?.toJson(),
    'pitchers': pitchers
        .map((pitcher) => (pitcher as PitcherDecisionModel).toJson())
        .toList(),
  };
}
