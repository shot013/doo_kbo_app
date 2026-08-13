import '../../../player/data/models/player_summary_model.dart';
import '../../domain/entities/team_detail.dart';
import 'team_summary_model.dart';

final class TeamDetailModel extends TeamDetail {
  const TeamDetailModel({required super.summary, required super.roster});

  factory TeamDetailModel.fromJson(Map<String, dynamic> json) {
    final rosterJson = json['roster'] as List<dynamic>? ?? const [];
    return TeamDetailModel(
      summary: TeamSummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      roster: rosterJson
          .map(
            (player) =>
                PlayerSummaryModel.fromJson(player as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
