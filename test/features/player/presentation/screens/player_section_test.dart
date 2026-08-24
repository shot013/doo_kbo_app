import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/features/player/data/datasources/player_remote_data_source.dart';
import 'package:jikgwan/features/player/presentation/providers/player_providers.dart';
import 'package:jikgwan/features/player/presentation/screens/player_section.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

void main() {
  testWidgets('shows the dummy player roster', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
          playerRemoteDataSourceProvider.overrideWithValue(
            const PlayerDummyDataSource(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: PlayerSection())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('선수'), findsOneWidget);
    expect(find.text('선수 투1'), findsOneWidget);
  });
}
