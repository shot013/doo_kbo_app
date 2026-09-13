# ERRORS.md

반복되거나 원인 파악에 시간이 걸렸던 에러/장애를 기록하는 문서입니다.
같은 문제를 다시 겪을 때 검색해서 바로 해결하는 것이 목적입니다.

작성 규칙:
- 사소하거나 한 번에 해결된 오타/타입 에러는 기록하지 않습니다.
- 재발 가능성이 있거나, 원인이 코드만 봐서는 바로 안 보이는 경우에 기록합니다.
- 아래 항목을 포함합니다: 증상 → 원인 → 해결 방법 → (선택) 재발 방지.

## 템플릿

```
### [YYYY-MM-DD] 에러 제목

**증상**: 무엇이 어떻게 실패했는지 (에러 메시지, 재현 조건)

**원인**: 근본 원인

**해결**: 실제로 어떻게 고쳤는지

**재발 방지**: (선택) 린트 규칙 추가, 테스트 추가 등
```

---

### [2026-08-19] 릴리즈 AAB가 debug 서명으로 빌드됨

**증상**: `flutter build appbundle --release`가 성공했지만, 생성된 AAB의 서명 인증서가 업로드 키스토어가 아닌 debug 키였다.

**원인**: 이전 작업(untracked 빌드 산출물 정리) 중 `rm -rf android ...`로 gitignore된 `android/key.properties`가 함께 삭제됨. `key.properties`가 없으면 Gradle이 조용히 debug 서명으로 폴백해 빌드 자체는 에러 없이 성공한다.

**해결**: 기록해둔 keystore 비밀번호로 `key.properties`를 재생성하고, `keytool -list` / AAB 안의 `META-INF/*.RSA`를 `openssl pkcs7`/`x509`로 추출해 SHA-256 지문이 업로드 키스토어와 일치하는지 직접 검증한 뒤 재빌드.

**재발 방지**: `key.properties`는 git에 없으므로 `rm -rf`류 정리 명령을 실행하기 전 gitignore된 파일이 대상에 포함되는지 확인한다. 릴리즈 AAB를 빌드할 때마다 서명 인증서 지문을 검증하는 습관을 들인다.

### [2026-08-23] 에뮬레이터에서 `adb shell input tap`/`swipe`가 먹지 않음

**증상**: `adb shell input tap x y`, `input swipe ...`, `input touchscreen tap ...`를 보내도 Flutter 앱 화면이 전혀 반응하지 않음(탭해도 네비게이션 안 됨, 스와이프해도 스크롤 안 됨). 반면 `adb shell input keyevent KEYCODE_HOME`은 정상 동작(런처로 이동)하고, `am start`로 앱 재실행도 정상 동작함 — 즉 keyevent/intent는 기기에 도달하지만 합성 터치(모션) 이벤트만 Flutter 엔진까지 전달되지 않는 것으로 보임.

**원인**: 파악하지 못함(이 세션에서는 근본 원인을 특정하지 못하고 우회도 실패). 에뮬레이터(`sdk_gphone16k_x86_64`, Android 17 preview) 또는 이 머신의 adb/에뮬레이터 조합에 특이한 문제로 추정.

**해결**: 이번엔 UI 변경 사항을 코드 리뷰(정적 분석 통과 + 표준 위젯 API 사용 확인)로만 검증하고 실제 스크린샷 확인은 생략함.

**재발 방지**: 다음에 에뮬레이터 터치 검증이 필요할 때 이 증상이 재현되면, 코드 문제가 아니라 알려진 환경 이슈임을 먼저 확인하고 시간을 낭비하지 않는다. 가능하면 에뮬레이터 재시작/재생성으로 먼저 시도해볼 것.

### [2026-09-08] "오늘의 경기" 카드를 눌러 프리뷰 화면으로 이동하면 디버그 모드에서만 ANR 발생

**증상**: 릴리즈 빌드/`flutter run --release`에서는 전혀 재현 안 됨. IDE에서 디버그 모드로 실행 중 "오늘의 경기" 카드를 탭해 `GamePreviewScreen`으로 이동하면 앱이 완전히 먹통이 되고, 15초 뒤 "JIKGWAN이(가) 응답하지 않음" ANR 다이얼로그가 뜸. logcat에는 `Input dispatching timed out ... Waited 15001ms for MotionEvent`만 찍히고 다른 단서가 없었음. `flutter run`(터미널, 디버거 미부착)으로는 재현 안 되고 IDE의 Run(디버거 부착)에서만 재현됨.

**원인**: 두 가지가 겹침.
1. `GameModel`에 `toJson()`이 없는 상태에서, "오늘의 경기" 카드가 go_router의 `extra`로 `GameModel` 인스턴스를 그대로 넘김(`context.pushNamed(..., extra: game)`). 라우터/DevTools가 현재 라우트 상태를 표시하려고 이 값을 직렬화하려다 `NoSuchMethodError: Class 'GameModel' has no instance method 'toJson'`를 던짐. 릴리즈 빌드는 이 예외를 지켜보는 디버거가 없어 조용히 무시되지만, IDE 디버거에 "예외 발생 시 중단" 설정이 있으면 그 순간 Dart isolate 전체가 완전히 정지해 입력을 못 받고, 결국 안드로이드가 ANR을 띄움.
2. (부차적 요인) `dioProvider`의 `LogInterceptor(requestBody: true, responseBody: true)`가 디버그 모드에서 `print()`로 요청/응답 전체를 한 번에 출력하는데, `preview`가 포함된 `/games` 응답처럼 본문이 큰 경우 안드로이드 logcat 파이프가 밀리며 메인 스레드가 지연될 수 있음. 단독으로는 ANR을 일으킬 정도는 아니었지만 1번과 겹치면 증상을 더 키움.

**해결**: `GameModel.toJson()`을 `fromJson`과 대칭으로 추가(도메인 필드 전체 + `GameStatus` → wire string 역매핑). `dio_client.dart`의 `LogInterceptor`는 `logPrint`를 `debugPrint` 기반으로 교체하고 한 줄을 1000자로 제한.

**재발 방지**: go_router `extra`로 Model 인스턴스를 넘기는 새 화면을 만들 때는 그 Model에 `toJson()`이 있는지 먼저 확인한다(`.claude/rules/architecture.md`에 규칙으로 추가함). `avoid_print` 린트는 `logPrint: print`처럼 함수를 값으로 참조하는 경우는 잡지 못하므로, 새 인터셉터/로거를 추가할 때 이 패턴을 직접 확인한다. 디버그 전용 증상은 CLI `flutter run`만으로는 재현이 안 될 수 있으니, IDE 디버거(특히 "예외 발생 시 중단" 설정)를 재현 조건에 포함해서 확인한다.
