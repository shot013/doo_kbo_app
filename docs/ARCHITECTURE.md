# 아키텍처

## 스택

| 영역 | 선택 |
|---|---|
| 상태 관리 / DI | Riverpod (`Provider`, `Notifier`, `AsyncNotifier`) |
| 라우팅 | go_router |
| 네트워크 | dio |
| 값 동등성 | equatable |
| 아키텍처 패턴 | Clean Architecture (feature-first + 계층 분리) |

## 폴더 구조

```
lib/
  main.dart                # runApp(ProviderScope(child: App()))
  app.dart                 # MaterialApp.router 설정
  core/
    constants/             # 환경설정 값 (API base url 등)
    error/                 # exceptions.dart(data layer), failures.dart(domain/presentation)
    network/                # dio_client.dart, network_info.dart
    router/                 # app_router.dart — feature 라우트 등록 지점
    theme/                  # AppTheme
    usecase/                # UseCase 기본 인터페이스
    utils/                  # Result<T> (Ok/Err) 공통 타입
  features/
    example/                # 새 feature 작성 시 복사할 템플릿 (README 참고)
      domain/                # entities, repositories(추상), usecases
      data/                  # models, datasources, repositories(구현)
      presentation/          # providers, screens
```

## 데이터 흐름

```
Screen (ConsumerWidget)
  → ref.watch(xxxProvider)               # presentation/providers
  → AsyncNotifier.build()
    → UseCase.call()                     # domain/usecases
      → Repository (interface)           # domain/repositories
        → RepositoryImpl                 # data/repositories
          → RemoteDataSource (Dio)       # data/datasources
          → NetworkInfo                  # core/network
```

- `domain`은 Flutter SDK, `data`, `presentation`에 의존하지 않는 순수 Dart 코드입니다.
- 에러는 예외(`ServerException` 등)로 발생시키고 `data/repositories`에서
  `Result<T>` (`Ok`/`Err`)로 변환해 상위 레이어로 올립니다.
- `presentation`은 `AsyncValue.when(data:, loading:, error:)`으로 상태를 분기합니다.

## 새 기능 추가 절차

1. `lib/features/example/`을 복사해 `lib/features/{기능명}/`으로 이름을 바꿉니다.
2. `domain/entities`, `domain/repositories`, `domain/usecases`부터 작성합니다.
3. `data`에서 인터페이스를 구현합니다.
4. `presentation/providers`에서 Riverpod provider로 연결합니다.
5. `core/router/app_router.dart`에 라우트를 추가합니다.
6. 기존 `example` 코드를 참고용으로 남겨둘지, 실제 기능이 늘어난 뒤 삭제할지는
   팀에서 정합니다.

## 협업 규칙

브랜치/커밋/PR 규칙은 [CONTRIBUTING.md](../CONTRIBUTING.md)를 참고하세요.
