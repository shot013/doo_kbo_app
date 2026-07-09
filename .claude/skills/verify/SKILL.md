---
name: verify
description: Verify a Dart/Flutter code change in doo_kbo_app by running the same checks as CI (format, analyze, test). Use before considering a change to lib/ or test/ done, or when asked to verify/check the app builds correctly.
---

# 변경 검증

CI(`.github/workflows/ci.yaml`)와 동일한 순서로 실행한다:

```
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

- `dart format`이 변경이 필요하다고 하면 플래그 없이 `dart format .`을 실행해 정리한다.
- `flutter analyze`는 경고 없이 통과해야 한다 (`analysis_options.yaml` 참고).
- 특정 파일/테스트만 검증하려면 `flutter test <path>` 또는 `flutter test <path> --plain-name "<name>"`을 사용한다.
- UI/화면 변경은 정적 검증만으로 충분하지 않다. 가능하면 `flutter run`으로 실제 동작을 확인한다.
