import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/checklist_model.dart';
import 'checklist_list_controller.dart';

class ChecklistListView extends GetView<ChecklistListController> {
  const ChecklistListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('체크리스트', style: AppTextStyles.title),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (controller.checklists.isEmpty) {
                    return _empty();
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: controller.load,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: controller.checklists.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final c = controller.checklists[i];
                        return _ChecklistCard(
                          checklist: c,
                          onTap: () => controller.openDetail(c.id),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fact_check_outlined,
              size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('체크리스트가 없어요', style: AppTextStyles.heading),
          const SizedBox(height: 8),
          Text(
            '기업 상세에서 체크리스트를 시작해보세요',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.checklist, required this.onTap});

  final Checklist checklist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (checklist.progress * 100).round();
    final done = checklist.isCompleted;
    final accent = done ? AppColors.good : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    checklist.companyName ?? '체크리스트',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: done
                        ? AppColors.goodSurface
                        : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    done ? '완료' : '진행중',
                    style: AppTextStyles.caption.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: checklist.progress,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$percent%',
                    style: AppTextStyles.caption.copyWith(color: accent)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
