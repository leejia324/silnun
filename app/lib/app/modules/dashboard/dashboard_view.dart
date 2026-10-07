import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/checklist_model.dart';
import '../../data/models/schedule_model.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Obx(() => Text('${controller.displayName}님',
                  style: AppTextStyles.title)),
              const SizedBox(height: 4),
              Text(
                '실습 준비, 실눈과 함께 확인해요',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              _searchBar(),
              const SizedBox(height: 32),
              _sectionHeader('진행 중인 체크리스트'),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.inProgress.isEmpty) {
                  return _emptyBox('진행 중인 체크리스트가 없어요');
                }
                return Column(
                  children: controller.inProgress
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ChecklistMini(
                              checklist: c,
                              onTap: () => controller.openChecklist(c.id),
                            ),
                          ))
                      .toList(),
                );
              }),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('다가오는 일정', style: AppTextStyles.heading),
                  GestureDetector(
                    onTap: controller.goSchedule,
                    child: Text('전체보기',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.upcoming.isEmpty) {
                  return _emptyBox('예정된 일정이 없어요');
                }
                return Column(
                  children: controller.upcoming
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ScheduleMini(schedule: s),
                          ))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return GestureDetector(
      onTap: controller.goSearch,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text('기업명·업종으로 검색해보세요',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textDisabled)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) =>
      Text(title, style: AppTextStyles.heading);

  Widget _emptyBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(message,
            style:
                AppTextStyles.body.copyWith(color: AppColors.textDisabled)),
      ),
    );
  }
}

class _ChecklistMini extends StatelessWidget {
  const _ChecklistMini({required this.checklist, required this.onTap});

  final Checklist checklist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (checklist.progress * 100).round();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(checklist.companyName ?? '체크리스트',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyStrong),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: checklist.progress,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('$percent%',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleMini extends StatelessWidget {
  const _ScheduleMini({required this.schedule});

  final ScheduleItem schedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${schedule.date.day}',
                style: AppTextStyles.bodyStrong
                    .copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schedule.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong),
                const SizedBox(height: 2),
                Text(
                  '${schedule.date.year}.${schedule.date.month.toString().padLeft(2, '0')}.${schedule.date.day.toString().padLeft(2, '0')}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
