---
name: add-feature
description: Scaffold a new feature module in this Flutter app by copying the lib/features/example Clean Architecture template (domain/data/presentation) and wiring it into the router. Use when asked to add, create, or scaffold a new feature or screen in doo_kbo_app.
---

# 새 feature 추가

`.claude/rules/architecture.md`의 의존 방향을 지키면서 아래 순서로 진행한다.

1. `lib/features/example/`을 `lib/features/{기능명}/`으로 복사한다. `{기능명}`은 소문자 snake_case.
2. `domain/entities`, `domain/repositories`, `domain/usecases`부터 새 도메인에 맞게 다시 작성한다.
3. `data/models`, `data/datasources`, `data/repositories`에서 domain 인터페이스를 구현한다. Model은 `fromJson`과 대칭으로 `toJson`도 만든다.
4. `presentation/providers`에서 Riverpod provider(`AsyncNotifier` 등)로 연결하고, `presentation/screens`에서 `AsyncValue.when`으로 상태를 분기한다.
5. `lib/core/router/app_router.dart`에 `GoRoute`를 추가한다.
6. 복사 원본 이름(`Team`, `team_...`, `TeamListNotifier`, `teamListProvider` 등)이 남아있지 않은지 확인한다. example의 식별자는 실제 `team` feature와 이름이 같아서, 남아있으면 import 충돌이나 엉뚱한 provider 참조로 이어진다.
7. `/verify`로 포맷·analyze·테스트를 통과시킨다.
