import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/game/domain/entities/pitcher_decision_type.dart';
import 'package:jikgwan/features/game_summary/data/datasources/game_summary_remote_data_source.dart';
import 'package:jikgwan/features/game_summary/domain/entities/game_summary.dart';
import 'package:jikgwan/features/game_summary/domain/entities/inning_half.dart';
import 'package:jikgwan/features/game_summary/domain/entities/line_score.dart';
import 'package:jikgwan/features/game_summary/domain/entities/pinch_hitter.dart';
import 'package:jikgwan/features/game_summary/domain/entities/pitcher_appearance.dart';
import 'package:jikgwan/features/game_summary/domain/entities/scoring_play.dart';

PitcherEntry _entry({
  int inning = 6,
  InningHalf? half = InningHalf.bottom,
  int? outs = 0,
  List<int> runners = const [],
  bool atInningStart = false,
}) => PitcherEntry(
  inning: inning,
  half: half,
  outs: outs,
  runners: runners,
  atInningStart: atInningStart,
);

PitcherAppearance _pitcher({
  PitcherRole role = PitcherRole.reliever,
  PitcherEntry? entry,
  int outs = 0,
  int? pitchCount,
  int? runs,
  PitcherDecisionType? decision,
}) => PitcherAppearance(
  playerId: null,
  playerName: '투수',
  role: role,
  entry: entry,
  outs: outs,
  pitchCount: pitchCount,
  runs: runs,
  decision: decision,
);

TeamLineScore _team(String code, List<int?> innings, int runs) => TeamLineScore(
  teamCode: code,
  innings: innings,
  runs: runs,
  hits: 0,
  errors: 0,
  walks: 0,
);

PinchHitterAppearance _pinch({
  String? replacedPlayerName = '노우익',
  String? pitcherName = '홍좌완',
  String? resultText = '2루타',
  bool isHit = true,
  int rbi = 1,
}) => PinchHitterAppearance(
  inning: 8,
  half: InningHalf.bottom,
  teamCode: 'LG',
  playerId: null,
  playerName: '표중견',
  replacedPlayerId: null,
  replacedPlayerName: replacedPlayerName,
  pitcherId: null,
  pitcherName: pitcherName,
  resultText: resultText,
  isHit: isHit,
  rbi: rbi,
);

void main() {
  group('PitcherEntry.label', () {
    test('shows outs and runners', () {
      expect(_entry(outs: 1, runners: [1]).label, '6회말 1사 1루');
      expect(_entry(outs: 0, runners: [2, 1]).label, '6회말 무사 1·2루');
      expect(_entry(outs: 2, runners: [1, 2, 3]).label, '6회말 2사 만루');
      expect(_entry(outs: 2).label, '6회말 2사');
    });

    test('shows inning start', () {
      expect(_entry(inning: 8, atInningStart: true).label, '8회말 시작');
    });

    test('shows only the inning when outs are unknown (KAN-8 v2)', () {
      expect(_entry(outs: null, runners: [1]).label, '6회말 등판');
      expect(_entry(outs: null, atInningStart: true).label, '6회말 시작');
    });
  });

  group('PitcherAppearance', () {
    test('formats innings pitched from outs', () {
      expect(_pitcher(outs: 16).inningsPitchedLabel, '5.1');
      expect(_pitcher(outs: 17).inningsPitchedLabel, '5.2');
      expect(_pitcher(outs: 3).inningsPitchedLabel, '1.0');
      expect(_pitcher().inningsPitchedLabel, '0.0');
    });

    test('labels the starter entry and missing values', () {
      final starter = _pitcher(role: PitcherRole.starter);

      expect(starter.entryLabel, '선발 등판');
      expect(starter.highlightsEntry, isFalse);
      expect(starter.pitchCountLabel, '-');
      expect(starter.runsLabel, '-');
      expect(starter.decisionLabel, isNull);
    });

    test('labels a reliever whose entry is unknown with a dash', () {
      final unknown = _pitcher();
      final known = _pitcher(entry: _entry(outs: 1, runners: [1]));

      expect(unknown.entryLabel, '-');
      expect(unknown.highlightsEntry, isFalse);
      expect(known.entryLabel, '6회말 1사 1루');
      expect(known.highlightsEntry, isTrue);
    });

    test('labels decisions', () {
      expect(_pitcher(decision: PitcherDecisionType.win).decisionLabel, '승');
      expect(_pitcher(decision: PitcherDecisionType.hold).decisionLabel, '홀');
    });
  });

  group('LineScore', () {
    test('picks the winner and leaves unplayed innings blank', () {
      final lineScore = LineScore(
        inningCount: 9,
        away: _team('OB', [0, 1, 0, 0, 2, 0, 0, 0, 0], 3),
        home: _team('LG', [1, 0, 0, 0, 0, 3, 0, 1, null], 5),
      );

      expect(lineScore.winnerTeamCode, 'LG');
      expect(lineScore.isDraw, isFalse);
      expect(lineScore.home.inningCells(9).last, '');
      expect(lineScore.home.runsInInning(9), 0);
      expect(lineScore.home.runsInInning(6), 3);
    });

    test('has no winner on a draw and pads extra innings', () {
      final lineScore = LineScore(
        inningCount: 11,
        away: _team('OB', [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], 1),
        home: _team('LG', [1, 0, 0, 0, 0, 0, 0, 0, 0], 1),
      );

      expect(lineScore.winnerTeamCode, isNull);
      expect(lineScore.isDraw, isTrue);
      expect(lineScore.inningHeaders.last, '11');
      expect(lineScore.home.inningCells(11).sublist(9), ['', '']);
    });
  });

  group('ScoringPlay', () {
    ScoringPlay play({bool isReversal = false, bool isTying = false}) =>
        ScoringPlay(
          inning: 6,
          half: InningHalf.bottom,
          teamCode: 'LG',
          description: '정내야 3점 홈런',
          homeScore: 4,
          awayScore: 3,
          isReversal: isReversal,
          isTying: isTying,
        );

    test('marks reversal and tying plays', () {
      expect(play(isReversal: true).descriptionText, '정내야 3점 홈런 (역전)');
      expect(play(isTying: true).descriptionText, '정내야 3점 홈런 (동점)');
      expect(play().descriptionText, '정내야 3점 홈런');
      expect(play().inningText, '6회말');
      expect(play().scoreText, '4:3');
    });
  });

  group('PinchHitterSummary.lineLabel', () {
    PinchHitterSummary summary(int atBats, int hits, int rbi) =>
        PinchHitterSummary(
          teamCode: 'LG',
          count: 1,
          atBats: atBats,
          hits: hits,
          rbi: rbi,
        );

    test('formats batting lines', () {
      expect(summary(1, 1, 1).lineLabel, '1타수 1안타 1타점');
      expect(summary(2, 0, 0).lineLabel, '2타수 무안타');
      expect(summary(2, 1, 0).lineLabel, '2타수 1안타');
      expect(summary(0, 0, 1).lineLabel, '타수 없음 1타점');
      expect(summary(2, 0, 0).countLabel, '대타 1명');
    });
  });

  group('PinchHitterAppearance', () {
    test('formats a hit with RBI', () {
      final pinch = _pinch();

      expect(pinch.title, '대타 표중견');
      expect(pinch.inningText, '8회말');
      expect(pinch.matchupText, '노우익 대신 · vs 홍좌완');
      expect(pinch.resultLabel, '2루타 · 1타점');
      expect(pinch.isGoodResult, isTrue);
    });

    test('formats an out and a pinch hitter who never batted', () {
      final out = _pinch(resultText: '삼진', isHit: false, rbi: 0);
      final neverBatted = _pinch(
        pitcherName: null,
        resultText: null,
        isHit: false,
        rbi: 0,
      );

      expect(out.resultLabel, '삼진');
      expect(out.isGoodResult, isFalse);
      expect(neverBatted.resultLabel, isNull);
      expect(neverBatted.matchupText, '노우익 대신');
    });
  });

  group('GameSummary', () {
    test('shows pitch count and runs columns when any value exists', () {
      expect(dummyGameSummary.showsPitchCount, isTrue);
      expect(dummyGameSummary.showsRuns, isTrue);
      expect(dummyGameSummary.totalOutsSlots, 27);
      expect(dummyGameSummary.hasPinchHitters, isTrue);
      expect(dummyGameSummary.isDetailPending, isFalse);
    });

    test('is not pending when a scoreless game has nothing to describe', () {
      const none = PinchHitterSummary(
        teamCode: 'OB',
        count: 0,
        atBats: 0,
        hits: 0,
        rbi: 0,
      );
      final scoreless = GameSummary(
        gameId: 'g',
        homeTeamCode: 'LG',
        awayTeamCode: 'OB',
        lineScore: LineScore(
          inningCount: 9,
          away: _team('OB', List.filled(9, 0), 0),
          home: _team('LG', List.filled(9, 0), 0),
        ),
        scoringPlays: const [],
        awayPitchers: [_pitcher(role: PitcherRole.starter, outs: 27)],
        homePitchers: [_pitcher(role: PitcherRole.starter, outs: 27)],
        awayPinchHitterSummary: none,
        homePinchHitterSummary: none,
        pinchHitterAppearances: const [],
      );

      expect(scoreless.isDetailPending, isFalse);
      expect(scoreless.hasPinchHitters, isFalse);
    });
  });
}
