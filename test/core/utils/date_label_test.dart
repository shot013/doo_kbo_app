import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/utils/date_label.dart';

void main() {
  test('formats dates with the Korean weekday', () {
    expect(koreanWeekday('2026-11-26'), '목');
    expect(koreanWeekday('2026-11-29'), '일');
    expect(dateWithWeekday('2026-11-26'), '2026-11-26 (목)');
    expect(monthDayLabel('2026-03-05'), '03.05');
    expect(isoDate(DateTime(2026, 3, 5, 23, 59)), '2026-03-05');
  });
}
