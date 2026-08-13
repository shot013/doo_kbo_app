final class KboTeam {
  const KboTeam(this.code, this.name);

  final String code;
  final String name;
}

/// KBO 10개 구단. 코드는 [lib/core/widgets/team_logo.dart]의 자산 맵과 일치해야 한다.
const List<KboTeam> kKboTeams = [
  KboTeam('KT', 'kt wiz'),
  KboTeam('SS', '삼성 라이온즈'),
  KboTeam('LG', 'LG 트윈스'),
  KboTeam('HT', 'KIA 타이거즈'),
  KboTeam('OB', '두산 베어스'),
  KboTeam('HH', '한화 이글스'),
  KboTeam('NC', 'NC 다이노스'),
  KboTeam('LT', '롯데 자이언츠'),
  KboTeam('SK', 'SSG 랜더스'),
  KboTeam('WO', '키움 히어로즈'),
];
