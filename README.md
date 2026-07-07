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
| 예시 기능 | `lib/features/example/` — KBO 팀 목록을 domain→data→presentation 전 계층으로 구현한 템플릿. 백엔드가 없어 기본은 `TeamDummyDataSource`가 연결되어 있고, API 준비 시 `TeamRemoteDataSourceImpl(dio)`로 교체 |

```
lib/
  main.dart / app.dart      # ProviderScope + MaterialApp.router
  core/                     # error, network, router, theme, usecase, utils
  features/
    example/                # 새 기능 작성 시 복사할 템플릿
      domain/  data/  presentation/
```