---
name: add-feature
description: Scaffold a new feature module in this Flutter app by copying the lib/features/example Clean Architecture template (domain/data/presentation) and wiring it into the router. Use when asked to add, create, or scaffold a new feature or screen in doo_kbo_app.
---

# 새 feature 추가

1. `lib/features/example/`을 `lib/features/{기능명}/`으로 복사한다. `{기능명}`은 소문자 snake_case.
2. `domain/entities`, `domain/repositories`, `domain/usecases`부터 새 도메인에 맞게 다시 작성한다.
   - `domain`은 Flutter SDK나 `data`/`presentation`을 import하지 않는다.
3. `data/models`, `data/datasources`, `data/repositories`에서 domain 인터페이스를 구현한다.
   - 예외(`ServerException` 등)는 `data/repositories`에서 `Result<T>`(`Ok`/`Err`)로 변환한다.
4. `presentation/providers`에서 Riverpod provider(`AsyncNotifier` 등)로 연결하고, `presentation/screens`에서 `AsyncValue.when`으로 상태를 분기한다.
5. `lib/core/router/app_router.dart`에 `GoRoute`를 추가한다.
6. 복사 원본인 `example` 관련 이름(`Team`, `team_...`)이 새 파일에 남아있지 않은지 확인한다.
7. `flutter analyze`와 `flutter test`를 실행해 통과하는지 확인한다 (verify 스킬 참고).

세부 규칙은 `.claude/rules/architecture.md`를 따른다.
