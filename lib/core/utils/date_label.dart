/// 화면에 쓰는 날짜 문자열 도우미. 서버 경기일은 `YYYY-MM-DD` 문자열이다.
library;

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

/// 예: `목`. [date]가 날짜 형식이 아니면 빈 문자열.
String koreanWeekday(String date) {
  final parsed = DateTime.tryParse(date);
  return parsed == null ? '' : _weekdays[parsed.weekday - 1];
}

/// 예: `2026-11-26 (목)`
String dateWithWeekday(String date) {
  final weekday = koreanWeekday(date);
  return weekday.isEmpty ? date : '$date ($weekday)';
}

/// 예: `11.26`
String monthDayLabel(String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;
  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  return '$month.$day';
}

/// 기기 시간대 기준 [time]의 날짜를 `YYYY-MM-DD`로 (HOME 오늘의 경기와 같은 기준).
String isoDate(DateTime time) {
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  return '${time.year}-$month-$day';
}
