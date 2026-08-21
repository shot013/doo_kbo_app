import 'package:equatable/equatable.dart';

import 'pitcher_decision_type.dart';

class PitcherDecision extends Equatable {
  const PitcherDecision({
    required this.decision,
    required this.playerName,
    required this.teamCode,
    required this.inningsPitched,
    required this.earnedRuns,
    required this.strikeoutsPitched,
    required this.era,
  });

  final PitcherDecisionType decision;
  final String playerName;
  final String teamCode;
  final String? inningsPitched;
  final int? earnedRuns;
  final int? strikeoutsPitched;
  final String? era;

  @override
  List<Object?> get props => [
    decision,
    playerName,
    teamCode,
    inningsPitched,
    earnedRuns,
    strikeoutsPitched,
    era,
  ];
}
