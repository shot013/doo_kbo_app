import 'package:equatable/equatable.dart';

class PitcherMatchup extends Equatable {
  const PitcherMatchup({
    required this.style,
    required this.seasonRecord,
    required this.headToHeadRecord,
    required this.era,
    required this.war,
    required this.games,
    required this.avgInnings,
    required this.qualityStarts,
    required this.whip,
  });

  final String? style;
  final String? seasonRecord;
  final String? headToHeadRecord;
  final String? era;
  final String? war;
  final String? games;
  final String? avgInnings;
  final String? qualityStarts;
  final String? whip;

  @override
  List<Object?> get props => [
    style,
    seasonRecord,
    headToHeadRecord,
    era,
    war,
    games,
    avgInnings,
    qualityStarts,
    whip,
  ];
}
