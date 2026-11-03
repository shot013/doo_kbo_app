# CLAUDE.md

@doo_kbo_harness_kit/KIT_RULES.md

위 키트 공통 규칙이 이 저장소의 첫 단계 규칙입니다. 이 파일과 `.claude/rules/*`는 그것을 doo_kbo_app에 맞게 구체화한 것입니다. 사람용 전체 규약은 `CONTRIBUTING.md`.

## 키트와 다른 점

- `.claude/rules/*`는 Claude Code가 자동 로드하므로 `@` import하지 않는다 (중복 로드 방지).
- 브랜치명은 `{type}/{desc}`로 이슈 번호를 선택 사항으로 하고 접두사를 넓게 허용하며, 커밋 타입에 `ci`를 추가했다. `guard-git`은 PowerShell 명령과 `git config` 변경도 검사한다 (`.claude/hooks/guard-git.sh`).

## 명령어

```
flutter pub get                                   # 의존성 설치
flutter run                                        # 앱 실행
dart format --output=none --set-exit-if-changed .  # 포맷 체크 (CI에서 사용; 플래그를 빼면 자동 포맷)
flutter analyze                                     # 정적 분석 (경고 없이 통과해야 함)
flutter test                                        # 전체 테스트 실행
flutter test test/widget_test.dart                  # 단일 테스트 파일 실행
flutter test test/widget_test.dart --plain-name "name" # 이름으로 단일 테스트 실행
```

CI(`.github/workflows/ci.yaml`)는 `main`/`develop`으로의 모든 PR/push에서 포맷 체크 → `flutter analyze` → `flutter test` 순으로 실행합니다. 병합 전 세 가지 모두 로컬에서 통과해야 합니다 (`/verify`).

## 아키텍처

Feature-first Clean Architecture. 상태 관리/DI는 Riverpod, 라우팅은 go_router, 네트워크는 dio, 값 동등성은 equatable.

```
lib/
  main.dart / app.dart   # runApp(ProviderScope(child: App())) + MaterialApp.router
  core/                  # constants, error(exceptions/failures), network(dioProvider), router(app_router), theme(AppColors), usecase, utils(Result<T>)
  features/{name}/
    domain/       # entities, repositories (추상), usecases — 순수 Dart
    data/         # models (entity 상속 + fromJson/toJson), datasources, repositories (구현)
    presentation/ # Riverpod providers, screens
```

데이터 흐름: `Screen (ConsumerWidget)` → `ref.watch(xxxProvider)` → `AsyncNotifier.build()` → `UseCase.call()` → `Repository` (domain) → `RepositoryImpl` (data) → `RemoteDataSource` (Dio) / `NetworkInfo`.

`lib/features/example/`은 새 feature를 만들 때 복사할 템플릿입니다. 절차는 `/add-feature` 스킬에 있습니다.
