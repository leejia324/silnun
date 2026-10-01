import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../home/home_controller.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('안녕하세요 👋', style: AppTextStyles.body),
              const SizedBox(height: 4),
              Text('${controller.displayName}님', style: AppTextStyles.title),
              const SizedBox(height: 4),
              Text(
                '오늘도 안전한 실습 준비해요',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _SearchCta(onTap: () => _goTab(1)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MenuCard(
                      icon: Icons.fact_check_outlined,
                      title: '체크리스트',
                      subtitle: '실습 준비 확인',
                      onTap: () => _goTab(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MenuCard(
                      icon: Icons.calendar_today_outlined,
                      title: '일정',
                      subtitle: '준비 일정 보기',
                      onTap: () => _goTab(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goTab(int index) => Get.find<HomeController>().changeTab(index);
}

class _SearchCta extends StatelessWidget {
  const _SearchCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '실습처 안전 이력 확인',
                    style: AppTextStyles.heading
                        .copyWith(color: AppColors.surface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '기업명으로 검색해보세요',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.search, color: AppColors.surface, size: 28),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 14),
            Text(title, style: AppTextStyles.bodyStrong),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
