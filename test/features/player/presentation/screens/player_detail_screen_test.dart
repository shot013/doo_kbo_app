import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/features/player/data/datasources/player_remote_data_source.dart';
import 'package:jikgwan/features/player/presentation/providers/player_providers.dart';
import 'package:jikgwan/features/player/presentation/screens/player_detail_screen.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

void main() {
  testWidgets('shows the player profile and vs-team stat section', (
    tester,
  ) async {
    // vsTeamStats/vsPitcherStats/vsBatterStats 세 섹션을 합치면 기본 테스트
    // 뷰포트보다 콘텐츠가 훨씬 길어져, 뷰포트+캐시 범위 밖의 ListView 항목은
    // Element가 아예 마운트되지 않아 find.text로 찾을 수 없다. 스크롤 없이
    // 전체를 한 번에 렌더링해서 검증할 수 있도록 뷰포트를 넉넉히 키운다.
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
          playerRemoteDataSourceProvider.overrideWithValue(
            const PlayerDummyDataSource(),
          ),
        ],
        child: const MaterialApp(home: PlayerDetailScreen(playerId: 'KT-투1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('선수 투1'), findsWidgets);
    expect(find.textContaining('kt wiz'), findsWidgets);
    expect(find.text('구단별 피안타율'), findsOneWidget);
    expect(find.text('상대 타자별 피안타율'), findsOneWidget);
    expect(find.text('상대 투수별 안타율'), findsNothing);
  });
}
