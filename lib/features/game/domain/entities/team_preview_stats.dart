import 'package:equatable/equatable.dart';

class TeamPreviewStats extends Equatable {
  const TeamPreviewStats({
    required this.record,
    required this.recentForm,
    required this.era,
    required this.battingAverage,
    required this.avgRunsScored,
    required this.avgRunsAllowed,
  });

  final String? record;
  final String? recentForm;
  final String? era;
  final String? battingAverage;
  final String? avgRunsScored;
  final String? avgRunsAllowed;

  @override
  List<Object?> get props => [
    record,
    recentForm,
    era,
    battingAverage,
    avgRunsScored,
    avgRunsAllowed,
  ];
}
