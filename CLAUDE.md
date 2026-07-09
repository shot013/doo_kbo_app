# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```
flutter pub get                                   # install dependencies
flutter run                                        # run the app
dart format --output=none --set-exit-if-changed .  # check formatting (CI uses this; drop the flags to auto-format)
flutter analyze                                     # static analysis (must be warning-free)
flutter test                                        # run all tests
flutter test test/widget_test.dart                  # run a single test file
flutter test test/widget_test.dart --plain-name "name" # run a single test by name
```

CI (`.github/workflows/ci.yaml`) runs format check → `flutter analyze` → `flutter test` on every PR/push to `main`/`develop`. All three must pass locally before merging.

## Architecture

Feature-first Clean Architecture. State/DI via Riverpod, routing via go_router, networking via dio, value equality via equatable.

```
lib/
  main.dart / app.dart   # runApp(ProviderScope(child: App())) + MaterialApp.router
  core/
    constants/            # env values (API base url, etc.)
    error/                # exceptions.dart (data-layer exceptions), failures.dart (AppFailure, used in domain/presentation)
    network/               # dio_client.dart (dioProvider), network_info.dart
    router/                 # app_router.dart — every feature registers its routes here
    theme/                  # AppTheme
    usecase/                # UseCase<ResultType, Params> base interface
    utils/                  # Result<T> (Ok/Err) sealed class — the return type for all usecases/repositories
  features/{name}/
    domain/     # entities, repositories (abstract), usecases — pure Dart, no Flutter SDK or data/presentation imports
    data/       # models (entity subclass + fromJson/toJson), datasources, repositories (impl)
    presentation/ # Riverpod providers, screens
```

Data flow: `Screen (ConsumerWidget)` → `ref.watch(xxxProvider)` → `AsyncNotifier.build()` → `UseCase.call()` → `Repository` (domain interface) → `RepositoryImpl` (data) → `RemoteDataSource` (Dio) / `NetworkInfo`.

- Errors are thrown as exceptions (e.g. `ServerException`) in the data layer, then converted to `Result<T>` (`Ok`/`Err` wrapping `AppFailure`) in `data/repositories` before flowing upward.
- `presentation` branches state with `AsyncValue.when(data:, loading:, error:)`.
- `domain` must not import Flutter SDK, `data`, or `presentation`.

`lib/features/example/` is a working reference implementation (KBO team list, all three layers) and the template to copy for new features — see `lib/features/example/README.md`. It defaults to `TeamDummyDataSource`; swap `teamRemoteDataSourceProvider` to `TeamRemoteDataSourceImpl(dio)` once a backend exists.

**New feature checklist** (from `docs/ARCHITECTURE.md`):
1. Copy `lib/features/example/` → `lib/features/{name}/`.
2. Write `domain/entities`, `domain/repositories`, `domain/usecases` first.
3. Implement the interfaces in `data`.
4. Wire up Riverpod providers in `presentation/providers`.
5. Register the route in `lib/core/router/app_router.dart`.

## Lint rules of note (`analysis_options.yaml`)

Stricter than default `flutter_lints` (chosen for a 6+ person team, to avoid style debates in review): `strict-casts`, `strict-inference`, `strict-raw-types`, `always_declare_return_types`, `avoid_print`, `prefer_relative_imports`, `prefer_final_locals`, `require_trailing_commas`, `unawaited_futures`.

## Collaboration (`CONTRIBUTING.md`)

- Branches: `main` (protected, PR-only), `develop` (integration), `feature/{issue}-{desc}`, `fix/{issue}-{desc}`, `chore/{desc}`, `release/{version}`.
- Commits: Conventional Commits — `<type>(<scope>): <subject>`, imperative, lowercase, no trailing period. Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`.
- One PR = one reviewable unit; requires 1+ approval; squash merge; `flutter analyze` and `flutter test` must pass locally before opening.
