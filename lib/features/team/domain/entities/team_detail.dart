import 'package:equatable/equatable.dart';

import '../../../player/domain/entities/player_summary.dart';
import 'team_summary.dart';

class TeamDetail extends Equatable {
  const TeamDetail({required this.summary, required this.roster});

  final TeamSummary summary;
  final List<PlayerSummary> roster;

  @override
  List<Object?> get props => [summary, roster];
}
