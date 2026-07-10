# doo_kbo_app

Flutter app scaffolded with Riverpod + go_router + dio on a
feature-first Clean Architecture layout, set up for a 6+ person team.

## 시작하기

```
flutter pub get
flutter run
```

## 문서

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — 폴더 구조, 데이터 흐름, 새 기능 추가 절차
- [CONTRIBUTING.md](CONTRIBUTING.md) — 브랜치 전략, 커밋 컨벤션, PR 규칙
- [docs/CLAUDE_CODE.md](docs/CLAUDE_CODE.md) — Claude Code가 이 저장소에서 자동으로 지키는 규칙/스킬/훅 정리

`lib/features/example/`은 새 기능을 만들 때 복사해서 시작하는 템플릿입니다.

## 구성 요약

| 영역 | 내용 |
|---|---|
| 상태 관리 / DI | Riverpod (`Provider`, `Notifier`, `AsyncNotifier`) |
| 라우팅 | go_router |
| 네트워크 | dio |
| 값 동등성 | equatable |
| 아키텍처 | Clean Architecture (feature-first, `domain`/`data`/`presentation` 계층 분리) |
| lint | `analysis_options.yaml`에 strict-casts/strict-inference, `unawaited_futures`, `require_trailing_commas` 등 팀 협업용 규칙 추가 |
| CI | `.github/workflows/ci.yaml` — PR/push마다 `dart format` 체크 + `flutter analyze` + `flutter test` |
| 협업 문서 | `CONTRIBUTING.md`(브랜치 전략, Conventional Commits, PR 규칙), `.github/PULL_REQUEST_TEMPLATE.md` |
| Claude Code 하네스 | `CLAUDE.md`/`.claude/rules/*`(항상 로드되는 규칙), `.claude/skills/*`(add-feature, verify), `.claude/hooks/*`(dart 파일 자동 포맷, 생성 파일 수정 차단), `.claude/agents/flutter-reviewer.md`(코드 리뷰 서브에이전트) — 정리는 [docs/CLAUDE_CODE.md](docs/CLAUDE_CODE.md) 참고 |
| 예시 기능 | `lib/features/example/` — KBO 팀 목록을 domain→data→presentation 전 계층으로 구현한 템플릿. 백엔드가 없어 기본은 `TeamDummyDataSource`가 연결되어 있고, API 준비 시 `TeamRemoteDataSourceImpl(dio)`로 교체 |

```
lib/
  main.dart / app.dart      # ProviderScope + MaterialApp.router
  core/                     # error, network, router, theme, usecase, utils
  features/
    example/                # 새 기능 작성 시 복사할 템플릿
      domain/  data/  presentation/
```

## 왜 이 아키텍처인가

- **Feature-first + 계층 분리(domain/data/presentation)**: 6인 이상 팀에서 여러 명이 동시에 다른 기능을 작업해도 폴더가 겹치지 않아 병합 충돌이 적고, 리뷰어가 `lib/features/{기능}/` 하나만 보면 그 기능의 전체 흐름을 파악할 수 있습니다.
- **domain 레이어의 순수성(Flutter SDK/`data`/`presentation` 비의존)**: UI나 네트워크 구현을 건드리지 않고도 비즈니스 로직(usecase)만 단위 테스트할 수 있고, 백엔드가 아직 없을 때는 `data`만 더미로 갈아끼우면 되므로(`example`의 `TeamDummyDataSource`처럼) 프론트엔드 개발이 API 완성을 기다릴 필요가 없습니다.
- **Riverpod**: 상태 관리와 의존성 주입을 하나의 도구로 처리해 provider 그래프만 보면 어떤 계층이 무엇에 의존하는지 추적할 수 있고, `AsyncNotifier` + `AsyncValue.when`으로 로딩/에러/성공 처리를 모든 화면에서 같은 패턴으로 강제합니다.
- **`Result<T>`(`Ok`/`Err`) 패턴**: 예외를 domain/presentation까지 그대로 전파시키지 않고 `data/repositories`에서 한 번에 `AppFailure`로 변환하도록 강제해, 에러 처리 누락으로 인한 크래시를 구조적으로 줄입니다.
- **엄격한 lint 규칙(`analysis_options.yaml`)**: 따옴표, trailing comma, import 경로처럼 사람마다 갈리기 쉬운 스타일을 기계적으로 통일해, 코드 리뷰가 스타일 논쟁이 아니라 로직 검토에 집중되도록 합니다.