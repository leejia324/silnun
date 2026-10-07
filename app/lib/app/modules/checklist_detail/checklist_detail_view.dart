import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/checklist_model.dart';
import 'checklist_detail_controller.dart';

class ChecklistDetailView extends GetView<ChecklistDetailController> {
  const ChecklistDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final c = controller.checklist.value;
        if (c == null) {
          return Center(
            child: Text('불러올 수 없어요',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
          );
        }
        final percent = (c.progress * 100).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.companyName ?? '체크리스트',
                      style: AppTextStyles.title),
                  const SizedBox(height: 16),
                  if (c.isCompleted) _completedBanner(),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: c.progress,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            color: c.isCompleted
                                ? AppColors.good
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$percent%',
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: c.isCompleted
                                ? AppColors.good
                                : AppColors.primary,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: _buildGrouped(c.items),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final c = controller.checklist.value;
        if (c == null || c.isCompleted) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: c.isCompleted || controller.isSubmitting.value
                    ? null
                    : () => _confirmComplete(context),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      )
                    : Text(c.isCompleted ? '완료됨' : '완료하기'),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _confirmComplete(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('체크리스트를 완료하시겠습니까?', style: AppTextStyles.heading),
              const SizedBox(height: 10),
              Text(
                '완료한 뒤에는 수정할 수 없습니다.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.textSecondary,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: AppTextStyles.button,
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.submit();
                      },
                      child: const Text('확인'),
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

  List<Widget> _buildGrouped(List<ChecklistItem> items) {
    final widgets = <Widget>[];
    String? current;
    for (final item in items) {
      if (item.category != current) {
        current = item.category;
        widgets.add(Padding(
          padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 20, bottom: 4),
          child: Text(item.category, style: AppTextStyles.heading),
        ));
      }
      final completed = controller.checklist.value?.isCompleted ?? false;
      widgets.add(_ItemTile(
        item: item,
        completed: completed,
        onTap: completed ? null : () => controller.toggle(item),
      ));
    }
    return widgets;
  }

  Widget _completedBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goodSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.good),
          const SizedBox(width: 12),
          Expanded(
            child: Text('체크리스트를 완료했어요',
                style:
                    AppTextStyles.bodyStrong.copyWith(color: AppColors.good)),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.completed,
    this.onTap,
  });

  final ChecklistItem item;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showX = completed && !item.checked;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.checked
                    ? AppColors.primary
                    : showX
                        ? AppColors.danger
                        : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.checked
                      ? AppColors.primary
                      : showX
                          ? AppColors.danger
                          : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              child: item.checked
                  ? const Icon(Icons.check, size: 16, color: AppColors.surface)
                  : showX
                      ? const Icon(Icons.close,
                          size: 16, color: AppColors.surface)
                      : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: AppTextStyles.body.copyWith(
                  color: item.checked
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (item.warning) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dangerSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 13, color: AppColors.dangerStrong),
                    const SizedBox(width: 4),
                    Text(
                      '위반 이력',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.dangerStrong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
