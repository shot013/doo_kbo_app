import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/game/domain/entities/pitcher_decision_type.dart';
import 'package:jikgwan/features/game_summary/data/datasources/game_summary_remote_data_source.dart';
import 'package:jikgwan/features/game_summary/data/models/game_summary_model.dart';
import 'package:jikgwan/features/game_summary/domain/entities/inning_half.dart';
import 'package:jikgwan/features/game_summary/domain/entities/pitcher_appearance.dart';

/// 백엔드 KAN-8 명세 v2의 예시 응답.
Map<String, dynamic> _specExample() => {
  'gameId': '20261126OBLG0',
  'homeTeamCode': 'LG',
  'awayTeamCode': 'OB',
  'lineScore': {
    'inningCount': 9,
    'away': {
      'teamCode': 'OB',
      'innings': [0, 1, 0, 0, 2, 0, 0, 0, 0],
      'runs': 3,
      'hits': 8,
      'errors': 1,
      'walks': 3,
    },
    'home': {
      'teamCode': 'LG',
      'innings': [1, 0, 0, 0, 0, 3, 0, 1, null],
      'runs': 5,
      'hits': 10,
      'errors': 0,
      'walks': 4,
    },
  },
  'scoringPlays': [
    {
      'inning': 6,
      'half': 'BOTTOM',
      'teamCode': 'LG',
      'description': '정내야 3점 홈런',
      'homeScore': 4,
      'awayScore': 3,
      'isReversal': true,
      'isTying': false,
    },
  ],
  'pitching': {
    'away': [
      {
        'playerId': 1001,
        'playerName': '정두산',
        'role': 'STARTER',
        'entry': null,
        'outs': 16,
        'pitchCount': 96,
        'runs': 4,
        'decision': 'LOSS',
      },
      {
        'playerId': 1002,
        'playerName': '이불펜',
        'role': 'RELIEVER',
        'entry': {
          'inning': 6,
          'half': 'BOTTOM',
          'outs': 1,
          'runners': [1],
          'atInningStart': false,
        },
        'outs': 5,
        'pitchCount': 22,
        'runs': 0,
        'decision': null,
      },
    ],
    'home': <Map<String, dynamic>>[],
  },
  'pinchHitters': {
    'summary': {
      'away': {'teamCode': 'OB', 'count': 2, 'atBats': 2, 'hits': 0, 'rbi': 0},
      'home': {'teamCode': 'LG', 'count': 1, 'atBats': 1, 'hits': 1, 'rbi': 1},
    },
    'appearances': [
      {
        'inning': 8,
        'half': 'BOTTOM',
        'teamCode': 'LG',
        'playerId': 2001,
        'playerName': '표중견',
        'replacedPlayerId': 2002,
        'replacedPlayerName': '노우익',
        'pitcherId': 1003,
        'pitcherName': '홍좌완',
        'resultText': '2루타',
        'isHit': true,
        'rbi': 1,
      },
    ],
  },
};

void main() {
  group('GameSummaryModel.fromJson', () {
    test('parses the KAN-8 spec example', () {
      final summary = GameSummaryModel.fromJson(_specExample());

      expect(summary.gameId, '20261126OBLG0');
      expect(summary.lineScore.inningCount, 9);
      expect(summary.lineScore.home.innings.last, isNull);
      expect(summary.lineScore.away.walks, 3);

      final play = summary.scoringPlays.single;
      expect(play.half, InningHalf.bottom);
      expect(play.isReversal, isTrue);

      expect(summary.awayPitchers, hasLength(2));
      expect(summary.awayPitchers.first.role, PitcherRole.starter);
      expect(summary.awayPitchers.first.entry, isNull);
      expect(summary.awayPitchers.first.decision, PitcherDecisionType.loss);
      expect(summary.awayPitchers[1].entry!.runners, [1]);
      expect(summary.awayPitchers[1].decision, isNull);
      expect(summary.homePitchers, isEmpty);

      expect(summary.homePinchHitterSummary.hits, 1);
      expect(summary.pinchHitterAppearances.single.pitcherName, '홍좌완');
    });

    test('blanks unknown enum values instead of failing (CODE-05)', () {
      final json = _specExample();
      final pitching = json['pitching'] as Map<String, dynamic>;
      final away = pitching['away'] as List<dynamic>;
      (away[0] as Map<String, dynamic>)
        ..['decision'] = 'BLOWN_SAVE'
        ..['role'] = 'OPENER';
      (away[1] as Map<String, dynamic>)['role'] = 'CLOSER';
      final plays = json['scoringPlays'] as List<dynamic>;
      (plays[0] as Map<String, dynamic>)['half'] = 'MIDDLE';

      final summary = GameSummaryModel.fromJson(json);

      expect(summary.awayPitchers[0].decision, isNull);
      // 등판 시점이 없으면 선발, 있으면 구원으로 본다.
      expect(summary.awayPitchers[0].role, PitcherRole.starter);
      expect(summary.awayPitchers[1].role, PitcherRole.reliever);
      expect(summary.scoringPlays.single.half, isNull);
      expect(summary.scoringPlays.single.inningText, '6회');
    });

    test('treats a missing pinch hitter summary as no pinch hitters', () {
      final json = _specExample()
        ..['pinchHitters'] = {'appearances': <Map<String, dynamic>>[]};

      final summary = GameSummaryModel.fromJson(json);

      expect(summary.awayPinchHitterSummary.teamCode, 'OB');
      expect(summary.awayPinchHitterSummary.count, 0);
      expect(summary.homePinchHitterSummary.teamCode, 'LG');
      expect(summary.hasPinchHitters, isFalse);
    });
  });

  group('GameSummaryModel.fromJson (KAN-8 v2 nulls)', () {
    Map<String, dynamic> pitcher(int index, Map<String, dynamic> json) =>
        ((json['pitching'] as Map<String, dynamic>)['away']
            as List<Map<String, dynamic>>)[index];
    List<Map<String, dynamic>> appearances(Map<String, dynamic> json) =>
        (json['pinchHitters'] as Map<String, dynamic>)['appearances']
            as List<Map<String, dynamic>>;

    test('accepts unknown entry outs, runners and RBI', () {
      final json = _specExample();
      pitcher(1, json)['entry'] = <String, dynamic>{
        'inning': 6,
        'half': 'BOTTOM',
        'outs': null,
        'runners': null,
        'atInningStart': false,
      };
      (json['pinchHitters'] as Map<String, dynamic>)['appearances'] = [
        <String, dynamic>{...appearances(json).single, 'rbi': null},
      ];

      final summary = GameSummaryModel.fromJson(json);

      expect(summary.awayPitchers[1].entryLabel, '6회말 등판');
      expect(summary.pinchHitterAppearances.single.rbi, 0);
      expect(summary.pinchHitterAppearances.single.resultLabel, '2루타');
    });

    test('parses a game without text relay yet', () {
      final json = _specExample()..['scoringPlays'] = <Map<String, dynamic>>[];
      pitcher(1, json)['entry'] = null;
      appearances(json).clear();

      final summary = GameSummaryModel.fromJson(json);

      expect(summary.scoringPlays, isEmpty);
      expect(summary.awayPitchers[1].entryLabel, '-');
      expect(summary.awayPitchers[1].highlightsEntry, isFalse);
      expect(summary.pinchHitterAppearances, isEmpty);
      expect(summary.isDetailPending, isTrue);
      // 팀별 대타 성적은 있으므로 대타 탭은 성적 카드를 보인다.
      expect(summary.hasPinchHitterStats, isTrue);
    });
  });

  group('GameSummaryModel.toJson', () {
    test('round-trips through fromJson', () {
      final restored = GameSummaryModel.fromJson(dummyGameSummary.toJson());

      expect(restored, dummyGameSummary);
    });
  });
}
