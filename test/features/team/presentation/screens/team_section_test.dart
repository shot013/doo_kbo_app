import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/features/team/data/datasources/team_remote_data_source.dart';
import 'package:jikgwan/features/team/presentation/providers/team_providers.dart';
import 'package:jikgwan/features/team/presentation/screens/team_section.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

void main() {
  testWidgets(
    'shows batting average, ERA, runs scored, and runs allowed for each team',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
            teamRemoteDataSourceProvider.overrideWithValue(
              const TeamDummyDataSource(),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: TeamSection())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('팀 타율'), findsWidgets);
      expect(find.text('팀 평균자책'), findsWidgets);
      expect(find.text('팀 득점'), findsWidgets);
      expect(find.text('팀 실점'), findsWidgets);
      expect(find.text('0.279'), findsOneWidget);
    },
  );
}
