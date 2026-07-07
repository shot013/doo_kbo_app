import 'package:doo_kbo_app/app.dart';
import 'package:doo_kbo_app/core/network/network_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

void main() {
  testWidgets('shows the KBO team list after loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // 실제 플러그인(connectivity_plus)의 플랫폼 채널을 타지 않도록
        // 테스트에서는 NetworkInfo를 오버라이드합니다.
        overrides: [
          networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
        ],
        child: const App(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Doosan Bears'), findsOneWidget);
  });
}
