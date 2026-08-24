import 'package:flutter/material.dart';

/// 앱 전역에서 쓰는 다크 팔레트. 화면마다 흩어져 있던 `Color(0xFF...)` 상수를
/// 여기 한 곳으로 모아 재사용한다.
abstract final class AppColors {
  static const Color background = Color(0xFF0C1E38);
  static const Color surface = Color(0xFF1B2C4D);
  static const Color surfaceHigh = Color(0xFF24365E);
  static const Color border = Color(0xFF3A4E73);
  static const Color textPrimary = Colors.white;
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color accent = Color(0xFF4ADE80);
  static const Color onAccent = Colors.black;
  static const Color gold = Color(0xFFFFC72C);
  static const Color navActive = Color(0xFF38BDF8);
}
