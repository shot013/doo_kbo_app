/// 이닝의 초(원정 공격)와 말(홈 공격).
enum InningHalf { top, bottom }

extension InningHalfLabel on InningHalf {
  String get label => switch (this) {
    InningHalf.top => '초',
    InningHalf.bottom => '말',
  };
}

/// `6회말`처럼 이닝과 초/말을 붙인 표기. 초/말을 모르면 `6회`만 쓴다.
String inningLabel(int inning, InningHalf? half) =>
    '$inning회${half?.label ?? ''}';
