import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_label.dart';

/// 경기 추가의 달력. [today] 뒤의 날짜는 고를 수 없다. 고른 날짜
/// `YYYY-MM-DD`를 돌려주고, 닫으면 null.
Future<String?> showAttendanceCalendar(
  BuildContext context, {
  required String selected,
  required String today,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) =>
        AttendanceCalendarDialog(selected: selected, today: today),
  );
}

class AttendanceCalendarDialog extends StatefulWidget {
  const AttendanceCalendarDialog({
    required this.selected,
    required this.today,
    super.key,
  });

  final String selected;
  final String today;

  @override
  State<AttendanceCalendarDialog> createState() =>
      _AttendanceCalendarDialogState();
}

class _AttendanceCalendarDialogState extends State<AttendanceCalendarDialog> {
  late DateTime _month;
  late final DateTime _today = DateTime.parse(widget.today);

  static const _weekdayHeaders = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    final selected = DateTime.tryParse(widget.selected) ?? _today;
    _month = DateTime(selected.year, selected.month);
  }

  bool get _canGoNext => DateTime(
    _month.year,
    _month.month + 1,
  ).isBefore(DateTime(_today.year, _today.month + 1));

  void _moveMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // DateTime.weekday: 월=1 … 일=7. 일요일부터 시작하는 칸에 맞춘다.
    final leading = DateTime(_month.year, _month.month).weekday % 7;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: '이전 달',
                  onPressed: () => _moveMonth(-1),
                  icon: const Icon(
                    Icons.chevron_left,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${_month.year}년 ${_month.month}월',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '다음 달',
                  onPressed: _canGoNext ? () => _moveMonth(1) : null,
                  icon: Icon(
                    Icons.chevron_right,
                    color: _canGoNext
                        ? AppColors.textPrimary
                        : AppColors.border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final header in _weekdayHeaders)
                  Expanded(
                    child: Text(
                      header,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < leading; i++) const SizedBox.shrink(),
                for (var day = 1; day <= daysInMonth; day++)
                  _DayCell(
                    date: isoDate(DateTime(_month.year, _month.month, day)),
                    day: day,
                    selected: widget.selected,
                    today: widget.today,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.day,
    required this.selected,
    required this.today,
  });

  final String date;
  final int day;
  final String selected;
  final String today;

  @override
  Widget build(BuildContext context) {
    final enabled = date.compareTo(today) <= 0;
    final isSelected = date == selected;
    return InkResponse(
      onTap: enabled ? () => Navigator.of(context).pop(date) : null,
      child: Container(
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.accent : null,
          border: date == today && !isSelected
              ? Border.all(color: AppColors.accent)
              : null,
        ),
        child: Text(
          '$day',
          style: TextStyle(
            color: isSelected
                ? AppColors.onAccent
                : enabled
                ? AppColors.textPrimary
                : AppColors.border,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
