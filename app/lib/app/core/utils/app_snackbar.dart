import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppSnackbar {
  AppSnackbar._();

  static void info(String message) =>
      _show(message, AppColors.primary, Icons.info_outline_rounded);

  static void success(String message) =>
      _show(message, AppColors.good, Icons.check_circle_outline_rounded);

  static void error(String message) =>
      _show(message, AppColors.danger, Icons.error_outline_rounded);

  static void _show(String message, Color color, IconData icon) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(icon, color: AppColors.surface, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.surface,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      snackPosition: SnackPosition.TOP,
      borderRadius: 14,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInOutCubic,
    );
  }
}
