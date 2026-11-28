import '../../../game/domain/entities/pitcher_decision_type.dart';
import '../../domain/entities/inning_half.dart';
import '../../domain/entities/pitcher_appearance.dart';

// 경기 요약 응답의 열거 값 변환. 모르는 값이 와도 예외를 던지지 않고 그 값만
// 비워서, 항목 하나 때문에 요약 전체가 오류가 되지 않게 한다 (정책서 CODE-05).

InningHalf? inningHalfFromJson(Object? value) => switch (value) {
  'TOP' => InningHalf.top,
  'BOTTOM' => InningHalf.bottom,
  _ => null,
};

String? inningHalfToJson(InningHalf? half) => switch (half) {
  InningHalf.top => 'TOP',
  InningHalf.bottom => 'BOTTOM',
  null => null,
};

/// 모르는 값이면 등판 시점 유무로 선발/구원을 정한다.
PitcherRole pitcherRoleFromJson(Object? value, {required bool hasEntry}) =>
    switch (value) {
      'STARTER' => PitcherRole.starter,
      'RELIEVER' => PitcherRole.reliever,
      _ => hasEntry ? PitcherRole.reliever : PitcherRole.starter,
    };

String pitcherRoleToJson(PitcherRole role) => switch (role) {
  PitcherRole.starter => 'STARTER',
  PitcherRole.reliever => 'RELIEVER',
};

PitcherDecisionType? decisionFromJson(Object? value) => switch (value) {
  'WIN' => PitcherDecisionType.win,
  'LOSS' => PitcherDecisionType.loss,
  'SAVE' => PitcherDecisionType.save,
  'HOLD' => PitcherDecisionType.hold,
  _ => null,
};

String? decisionToJson(PitcherDecisionType? decision) => switch (decision) {
  PitcherDecisionType.win => 'WIN',
  PitcherDecisionType.loss => 'LOSS',
  PitcherDecisionType.save => 'SAVE',
  PitcherDecisionType.hold => 'HOLD',
  null => null,
};
