import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/utils/result.dart';
import 'package:jikgwan/features/favorite_team/data/repositories/favorite_team_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FavoriteTeamRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    repository = FavoriteTeamRepositoryImpl(preferences);
  });

  group('FavoriteTeamRepositoryImpl', () {
    test('getFavoriteTeamCode returns null when nothing was saved', () async {
      final result = await repository.getFavoriteTeamCode();

      expect(result, isA<Ok<String?>>());
      expect((result as Ok<String?>).value, isNull);
    });

    test('setFavoriteTeamCode persists the code for later reads', () async {
      await repository.setFavoriteTeamCode('KT');

      final result = await repository.getFavoriteTeamCode();

      expect(result, isA<Ok<String?>>());
      expect((result as Ok<String?>).value, 'KT');
    });

    test('setFavoriteTeamCode(null) clears a previously saved code', () async {
      await repository.setFavoriteTeamCode('KT');
      await repository.setFavoriteTeamCode(null);

      final result = await repository.getFavoriteTeamCode();

      expect(result, isA<Ok<String?>>());
      expect((result as Ok<String?>).value, isNull);
    });

    test('a second repository instance sees what the first saved', () async {
      await repository.setFavoriteTeamCode('LT');

      final preferences = await SharedPreferences.getInstance();
      final reopened = FavoriteTeamRepositoryImpl(preferences);
      final result = await reopened.getFavoriteTeamCode();

      expect(result, isA<Ok<String?>>());
      expect((result as Ok<String?>).value, 'LT');
    });
  });
}
