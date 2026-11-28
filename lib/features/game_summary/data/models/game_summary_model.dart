import '../../domain/entities/game_summary.dart';
import 'line_score_model.dart';
import 'pinch_hitter_model.dart';
import 'pitcher_appearance_model.dart';
import 'scoring_play_model.dart';

/// `GET /game-summaries/{gameId}` 응답 (백엔드 KAN-8 명세 초안 v1).
final class GameSummaryModel extends GameSummary {
  const GameSummaryModel({
    required super.gameId,
    required super.homeTeamCode,
    required super.awayTeamCode,
    required super.lineScore,
    required super.scoringPlays,
    required super.awayPitchers,
    required super.homePitchers,
    required super.awayPinchHitterSummary,
    required super.homePinchHitterSummary,
    required super.pinchHitterAppearances,
  });

  factory GameSummaryModel.fromJson(Map<String, dynamic> json) {
    final pitching = json['pitching'] as Map<String, dynamic>? ?? const {};
    final pinchHitters =
        json['pinchHitters'] as Map<String, dynamic>? ?? const {};
    final pinchSummary =
        pinchHitters['summary'] as Map<String, dynamic>? ?? const {};
    final homeTeamCode = json['homeTeamCode'] as String;
    final awayTeamCode = json['awayTeamCode'] as String;

    return GameSummaryModel(
      gameId: json['gameId'] as String,
      homeTeamCode: homeTeamCode,
      awayTeamCode: awayTeamCode,
      lineScore: LineScoreModel.fromJson(
        json['lineScore'] as Map<String, dynamic>,
      ),
      scoringPlays: _list(json['scoringPlays'], ScoringPlayModel.fromJson),
      awayPitchers: _list(pitching['away'], PitcherAppearanceModel.fromJson),
      homePitchers: _list(pitching['home'], PitcherAppearanceModel.fromJson),
      awayPinchHitterSummary: _summary(pinchSummary['away'], awayTeamCode),
      homePinchHitterSummary: _summary(pinchSummary['home'], homeTeamCode),
      pinchHitterAppearances: _list(
        pinchHitters['appearances'],
        PinchHitterAppearanceModel.fromJson,
      ),
    );
  }

  static List<T> _list<T>(
    Object? json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return (json as List<dynamic>? ?? const [])
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 대타 합계가 빠져 있으면 대타가 없었던 것으로 본다.
  static PinchHitterSummaryModel _summary(Object? json, String teamCode) {
    if (json == null) {
      return PinchHitterSummaryModel(
        teamCode: teamCode,
        count: 0,
        atBats: 0,
        hits: 0,
        rbi: 0,
      );
    }
    return PinchHitterSummaryModel.fromJson(json as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'homeTeamCode': homeTeamCode,
    'awayTeamCode': awayTeamCode,
    'lineScore': (lineScore as LineScoreModel).toJson(),
    'scoringPlays': scoringPlays
        .map((play) => (play as ScoringPlayModel).toJson())
        .toList(),
    'pitching': {
      'away': awayPitchers
          .map((pitcher) => (pitcher as PitcherAppearanceModel).toJson())
          .toList(),
      'home': homePitchers
          .map((pitcher) => (pitcher as PitcherAppearanceModel).toJson())
          .toList(),
    },
    'pinchHitters': {
      'summary': {
        'away': (awayPinchHitterSummary as PinchHitterSummaryModel).toJson(),
        'home': (homePinchHitterSummary as PinchHitterSummaryModel).toJson(),
      },
      'appearances': pinchHitterAppearances
          .map(
            (appearance) => (appearance as PinchHitterAppearanceModel).toJson(),
          )
          .toList(),
    },
  };
}
