import 'package:equatable/equatable.dart';

/// 선수 상세 화면에 표시할 범용 스탯 한 줄(예: "타율" / ".320").
class PlayerStatLine extends Equatable {
  const PlayerStatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  List<Object?> get props => [label, value];
}
