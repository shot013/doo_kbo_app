# example 기능 (템플릿)

새 기능을 추가할 때 이 폴더를 복사해서 시작하세요. 실제 기능이 아니라
Clean Architecture 계층 구성을 보여주기 위한 참고용 스캐폴딩입니다.

```
example/
  domain/            # 프레임워크 독립적인 비즈니스 규칙
    entities/        # 순수 Dart 모델 (Team)
    repositories/     # 추상 인터페이스 (TeamRepository)
    usecases/        # 단일 책임 유스케이스 (GetTeams)
  data/              # domain의 인터페이스를 구현
    models/          # entity를 상속 + fromJson/toJson (TeamModel)
    datasources/     # 원격/로컬 데이터 소스 (Dio 등)
    repositories/     # TeamRepositoryImpl
  presentation/      # Riverpod provider + 위젯
    providers/
    screens/
```

## 백엔드 연동 전 상태

`TeamDummyDataSource`가 기본으로 연결되어 있어 백엔드 없이도 화면이 바로
동작합니다. API가 준비되면 `presentation/providers/team_providers.dart`의
`teamRemoteDataSourceProvider`를 `TeamRemoteDataSourceImpl(dio)`로 교체하세요.

## 규칙
- `domain`은 `data`, `presentation`, Flutter SDK를 import하지 않습니다.
- 화면은 provider(`AsyncNotifier`)를 통해서만 상태를 읽고, 성공/실패는
  `AsyncValue.when`으로 처리합니다.
- 에러는 `core/error/failures.dart`의 `AppFailure` 하위 타입으로 표현합니다.
- 새 기능 추가 시 `lib/core/router/app_router.dart`에 라우트를 등록하세요.
