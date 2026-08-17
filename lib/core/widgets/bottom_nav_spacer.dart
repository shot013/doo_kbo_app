import 'package:flutter/material.dart';

/// 플로팅 [AppBottomNav]에 스크롤 콘텐츠 마지막 줄이 가려지지 않도록
/// 목록 맨 아래에 넣는 여백입니다.
class BottomNavSpacer extends StatelessWidget {
  const BottomNavSpacer({super.key});

  static const double height = 80;

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: height);
  }
}
