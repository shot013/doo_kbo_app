# CLAUDE.md

이 파일은 이 저장소에서 작업하는 Claude Code(claude.ai/code)에게 제공되는 가이드입니다.

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

CI(`.github/workflows/ci.yaml`)는 `main`/`develop`으로의 모든 PR/push에서 포맷 체크 → `flutter analyze` → `flutter test` 순으로 실행합니다. 병합 전 세 가지 모두 로컬에서 통과해야 합니다.

## 아키텍처

Feature-first Clean Architecture. 상태 관리/DI는 Riverpod, 라우팅은 go_router, 네트워크는 dio, 값 동등성은 equatable을 사용합니다.

```
lib/
  main.dart / app.dart   # runApp(ProviderScope(child: App())) + MaterialApp.router
  core/
    constants/            # 환경 값 (API base url 등)
    error/                # exceptions.dart (data layer 예외), failures.dart (AppFailure, domain/presentation에서 사용)
    network/               # dio_client.dart (dioProvider), network_info.dart
    router/                 # app_router.dart — 모든 feature가 여기에 라우트를 등록
    theme/                  # AppTheme
    usecase/                # UseCase<ResultType, Params> 기본 인터페이스
    utils/                  # Result<T> (Ok/Err) sealed class — 모든 usecase/repository의 반환 타입
  features/{name}/
    domain/     # entities, repositories (추상), usecases — 순수 Dart, Flutter SDK나 data/presentation import 없음
    data/       # models (entity 상속 + fromJson/toJson), datasources, repositories (구현)
    presentation/ # Riverpod providers, screens
```

데이터 흐름: `Screen (ConsumerWidget)` → `ref.watch(xxxProvider)` → `AsyncNotifier.build()` → `UseCase.call()` → `Repository` (domain 인터페이스) → `RepositoryImpl` (data) → `RemoteDataSource` (Dio) / `NetworkInfo`.

- 에러는 data layer에서 예외(예: `ServerException`)로 던져지고, 상위로 전달되기 전에 `data/repositories`에서 `Result<T>` (`AppFailure`를 감싼 `Ok`/`Err`)로 변환됩니다.
- `presentation`은 `AsyncValue.when(data:, loading:, error:)`로 상태를 분기합니다.
- `domain`은 Flutter SDK, `data`, `presentation`을 import하면 안 됩니다.

`lib/features/example/`은 실제로 동작하는 참고 구현체(KBO 팀 목록, 3계층 전부)이자 새 feature를 만들 때 복사할 템플릿입니다 — `lib/features/example/README.md` 참고. 기본값은 `TeamDummyDataSource`이며, 백엔드가 준비되면 `teamRemoteDataSourceProvider`를 `TeamRemoteDataSourceImpl(dio)`로 교체하세요.

**새 feature 체크리스트** (`docs/ARCHITECTURE.md` 참고):
1. `lib/features/example/` → `lib/features/{name}/`으로 복사.
2. `domain/entities`, `domain/repositories`, `domain/usecases`부터 작성.
3. `data`에서 인터페이스를 구현.
4. `presentation/providers`에서 Riverpod provider 연결.
5. `lib/core/router/app_router.dart`에 라우트 등록.

## 주요 린트 규칙 (`analysis_options.yaml`)

6인 이상 팀에서 리뷰 시 스타일 논쟁을 줄이기 위해 기본 `flutter_lints`보다 엄격하게 설정: `strict-casts`, `strict-inference`, `strict-raw-types`, `always_declare_return_types`, `avoid_print`, `prefer_relative_imports`, `prefer_final_locals`, `require_trailing_commas`, `unawaited_futures`.

## 협업 (`CONTRIBUTING.md`)

- 브랜치: `main` (보호됨, PR 전용), `develop` (통합), `feature/{issue}-{desc}`, `fix/{issue}-{desc}`, `chore/{desc}`, `release/{version}`.
- 커밋: Conventional Commits — `<type>(<scope>): <subject>`, 명령형, 소문자 시작, 마침표 없음. 타입: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`.
- PR 하나 = 리뷰 가능한 단위 하나; 최소 1명 승인 필요; squash merge; PR 열기 전 로컬에서 `flutter analyze`와 `flutter test`가 통과해야 함.

## Claude Code 작업 규칙

- PR은 항상 `main`이 아니라 `develop`을 대상(base)으로 한다. `gh` CLI를 쓸 수 없는 환경이므로, PR을 만들어달라는 요청에는 실제로 클릭 가능한 비교 링크를 매번 제공한다: `https://github.com/shot013/doo_kbo_app/compare/develop...{branch}?expand=1`.
- 위 링크에 `&title=`, `&body=`를 URL-인코딩해 추가하면 GitHub의 "Open a pull request" 폼에 제목/본문이 미리 채워진다. 제목은 커밋 메시지와 동일한 Conventional Commits 형식(`<type>(<scope>): <subject>`), 본문은 항상 `.github/PULL_REQUEST_TEMPLATE.md` 형식(`## 변경 사항` / `## 테스트 방법` — 체크박스는 실제로 수행한 항목만 `[x]` — / `## 관련 이슈`)을 그대로 채워서 링크와 채팅 메시지 양쪽에 제시한다.
- 새로운 독립적인 변경마다 `develop`에서 새 브랜치를 만든다. 이미 다른 브랜치에 PR이 열려 있고 아직 머지되지 않았다면 그 브랜치를 이어서 쓰고, 성격이 다른 변경이면 별도 브랜치로 분리한다.
- 커밋하기 전에 `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test`를 모두 통과시킨다.
- 작업 디렉터리에 이미 사용자가(IDE 등에서) 만들어둔, 지금 요청과 무관한 미커밋 변경이 있으면 건드리지 않는다. `git stash push -- <해당 파일들>`로 분리해서 별도 브랜치로 옮긴 뒤, 작업이 끝나면 원래 있던 파일/브랜치로 되돌려 놓는다(stash pop).
- UI/프론트엔드 변경은 가능하면 에뮬레이터(`flutter run -d emulator-5554`)에서 실제로 띄워 스크린샷으로 확인한 뒤 커밋한다.
- 커밋/푸시/PR 생성은 사용자가 명시적으로 요청했을 때만 수행한다.
- `MEMORY.md`(코드/git 히스토리만으로 알 수 없는 결정·진행 상황·배경)와 `ERRORS.md`(재발 가능하거나 원인 파악에 시간이 걸렸던 에러)는 이 저장소가 채택한 `doo_kbo_harness_kit` 문서 관례다. 작업 시작 전 관련 있으면 참고하고, 주요 결정을 내리거나 까다로운 에러를 해결했다면 각 파일의 작성 규칙에 맞춰 갱신한다.
