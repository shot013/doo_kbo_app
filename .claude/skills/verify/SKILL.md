---
name: verify
description: Verify a Dart/Flutter code change in doo_kbo_app by running the same checks as CI (format, analyze, test). Use before considering a change to lib/ or test/ done, before committing, or when asked to verify/check the app builds correctly.
---

# 변경 검증

CI(`.github/workflows/ci.yaml`)와 동일한 순서로 실행한다:

```
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

- `dart format`이 변경이 필요하다고 하면 플래그 없이 `dart format .`을 실행해 정리한다.
- `flutter analyze`는 경고 없이 통과해야 한다.
- 특정 파일/테스트만 검증하려면 `flutter test <path>` 또는 `flutter test <path> --plain-name "<name>"`을 사용한다.
- `.githooks/pre-push` 훅이 같은 검증을 push 때 다시 돌리지만, 안전망일 뿐 이 검증을 대체하지 않는다.
- UI/화면 변경은 정적 검증만으로 충분하지 않다. 가능하면 에뮬레이터(`flutter run -d emulator-5554`)에서 띄워 스크린샷으로 확인한 뒤 커밋한다. 에뮬레이터 터치 입력이 먹지 않으면 `ERRORS.md`의 2026-08-23 항목을 먼저 확인한다.
