enum PlayerPosition { pitcher, catcher, infielder, outfielder }

extension PlayerPositionLabel on PlayerPosition {
  String get displayName => switch (this) {
    PlayerPosition.pitcher => '투수',
    PlayerPosition.catcher => '포수',
    PlayerPosition.infielder => '내야수',
    PlayerPosition.outfielder => '외야수',
  };
}
