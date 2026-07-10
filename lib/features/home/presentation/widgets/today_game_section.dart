import 'package:flutter/material.dart';

class TodayGameSection extends StatelessWidget {
  const TodayGameSection({super.key, required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel,
          style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '오늘의 경기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Text(
                  '더보기',
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 18),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _EmptyGameCard(),
      ],
    );
  }
}

class _EmptyGameCard extends StatelessWidget {
  const _EmptyGameCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3C),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_baseball,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '오늘은 MY팀 경기가 없습니다',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '예정된 경기가 없는 날이에요',
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF3A3A3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '최근경기 요약 보러가기',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
