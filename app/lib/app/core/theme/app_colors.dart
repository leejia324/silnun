import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6880EE);
  static const Color primarySurface = Color(0xFFE9EDFC);

  static const Color textPrimary = Color(0xFF191F28);
  static const Color textSecondary = Color(0xFF6B7684);
  static const Color textDisabled = Color(0xFFADB5BD);

  static const Color border = Color(0xFFE5E8EB);
  static const Color borderStrong = Color(0xFFC1C7CD);

  static const Color background = Color(0xFFF2F4F6);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color danger = Color(0xFFC0525A);
  static const Color dangerStrong = Color(0xFFB42318);
  static const Color dangerSurface = Color(0xFFF6E6E6);

  static const Color caution = Color(0xFFF08C00);
  static const Color cautionSurface = Color(0xFFFFF4E6);

  static const Color good = Color(0xFF12B886);
  static const Color goodSurface = Color(0xFFE6F7F1);

  static const Color noData = Color(0xFFADB5BD);
  static const Color noDataSurface = Color(0xFFF2F4F6);

  static Color riskColor(String level) {
    switch (level) {
      case 'danger':
        return danger;
      case 'caution':
        return caution;
      case 'good':
        return good;
      default:
        return noData;
    }
  }

  static Color riskSurface(String level) {
    switch (level) {
      case 'danger':
        return dangerSurface;
      case 'caution':
        return cautionSurface;
      case 'good':
        return goodSurface;
      default:
        return noDataSurface;
    }
  }

  static String riskLabel(String level) {
    switch (level) {
      case 'danger':
        return '위험';
      case 'caution':
        return '주의';
      case 'good':
        return '양호';
      default:
        return '정보없음';
    }
  }
}
