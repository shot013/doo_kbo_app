import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/utils/team_name.dart';

void main() {
  group('shortTeamName', () {
    test('takes the first word of a Korean team name', () {
      expect(shortTeamName('LG 트윈스'), 'LG');
      expect(shortTeamName('두산 베어스'), '두산');
    });

    test('uppercases lowercase-branded team names', () {
      expect(shortTeamName('kt wiz'), 'KT');
    });
  });
}
