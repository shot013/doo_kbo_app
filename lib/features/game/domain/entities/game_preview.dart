import 'package:equatable/equatable.dart';

import 'pitcher_matchup.dart';
import 'team_preview_stats.dart';

class GamePreview extends Equatable {
  const GamePreview({
    required this.gameId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homePitcher,
    required this.awayPitcher,
    required this.scrapedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String gameId;
  final TeamPreviewStats homeTeam;
  final TeamPreviewStats awayTeam;
  final PitcherMatchup homePitcher;
  final PitcherMatchup awayPitcher;
  final DateTime scrapedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    gameId,
    homeTeam,
    awayTeam,
    homePitcher,
    awayPitcher,
    scrapedAt,
    createdAt,
    updatedAt,
  ];
}
