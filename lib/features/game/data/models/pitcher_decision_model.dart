import '../../domain/entities/pitcher_decision.dart';
import '../../domain/entities/pitcher_decision_type.dart';

final class PitcherDecisionModel extends PitcherDecision {
  const PitcherDecisionModel({
    required super.decision,
    required super.playerName,
    required super.teamCode,
    required super.inningsPitched,
    required super.earnedRuns,
    required super.strikeoutsPitched,
    required super.era,
  });

  factory PitcherDecisionModel.fromJson(Map<String, dynamic> json) {
    return PitcherDecisionModel(
      decision: _decisionFromJson(json['decision'] as String),
      playerName: json['playerName'] as String,
      teamCode: json['teamCode'] as String,
      inningsPitched: json['inningsPitched'] as String?,
      earnedRuns: json['earnedRuns'] as int?,
      strikeoutsPitched: json['strikeoutsPitched'] as int?,
      era: json['era'] as String?,
    );
  }

  static PitcherDecisionType _decisionFromJson(String value) {
    return switch (value) {
      'WIN' => PitcherDecisionType.win,
      'LOSS' => PitcherDecisionType.loss,
      'SAVE' => PitcherDecisionType.save,
      'HOLD' => PitcherDecisionType.hold,
      _ => throw ArgumentError('Unknown PitcherDecisionType: $value'),
    };
  }
}
