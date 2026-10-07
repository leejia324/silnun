import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/schedule_model.dart';
import 'schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('일정', style: AppTextStyles.title),
                  GestureDetector(
                    onTap: () => _showEditor(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('추가',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => TableCalendar<ScheduleItem>(
                locale: 'ko_KR',
                firstDay: DateTime(2020),
                lastDay: DateTime(2100),
                focusedDay: controller.focusedDay.value,
                selectedDayPredicate: (d) =>
                    isSameDay(d, controller.selectedDay.value),
                eventLoader: controller.eventsOf,
                onDaySelected: controller.selectDay,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: AppTextStyles.bodyStrong,
                  leftChevronIcon: const Icon(Icons.chevron_left,
                      color: AppColors.textSecondary),
                  rightChevronIcon: const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: AppTextStyles.caption,
                  weekendStyle: AppTextStyles.caption,
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle:
                      AppTextStyles.body.copyWith(color: AppColors.primary),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle:
                      AppTextStyles.body.copyWith(color: AppColors.surface),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: Obx(() {
                final items = controller.selectedSchedules;
                if (items.isEmpty) {
                  return Center(
                    child: Text('이 날짜에 일정이 없어요',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textDisabled)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ScheduleCard(
                    schedule: items[i],
                    onTap: () => _showEditor(context, existing: items[i]),
                    onDelete: () => controller.remove(items[i].id),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditor(BuildContext context, {ScheduleItem? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final focused = Rx<DateTime>(existing?.date ?? controller.selectedDay.value);
    final picked = <DateTime>[
      existing?.date ?? controller.selectedDay.value,
    ].obs;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? '일정 추가' : '일정 수정',
                  style: AppTextStyles.heading),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: '일정 제목'),
              ),
              const SizedBox(height: 8),
              if (existing == null)
                Text('날짜를 눌러 여러 날 선택할 수 있어요',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Obx(
                () => TableCalendar<void>(
                  locale: 'ko_KR',
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2100),
                  focusedDay: focused.value,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: AppTextStyles.bodyStrong,
                    leftChevronIcon: const Icon(Icons.chevron_left,
                        color: AppColors.textSecondary),
                    rightChevronIcon: const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: AppTextStyles.caption,
                    weekendStyle: AppTextStyles.caption,
                  ),
                  selectedDayPredicate: (d) =>
                      picked.any((p) => isSameDay(p, d)),
                  onDaySelected: (sel, foc) {
                    focused.value = foc;
                    if (existing != null) {
                      picked.value = [sel];
                      return;
                    }
                    final idx = picked.indexWhere((p) => isSameDay(p, sel));
                    if (idx >= 0) {
                      picked.removeAt(idx);
                    } else {
                      picked.add(sel);
                    }
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: const BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: AppTextStyles.body
                        .copyWith(color: AppColors.primary),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: AppTextStyles.body
                        .copyWith(color: AppColors.surface),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: AppTextStyles.button,
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty || picked.isEmpty) {
                          return;
                        }
                        Get.back();
                        if (existing == null) {
                          controller.createMany(title, picked.toList());
                        } else {
                          controller.edit(existing.id, title, picked.first);
                        }
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
}

String _fmtDate(DateTime d) {
  const days = ['월', '화', '수', '목', '금', '토', '일'];
  return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')} (${days[d.weekday - 1]})';
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.onTap,
    required this.onDelete,
  });

  final ScheduleItem schedule;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          schedule.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyStrong,
                        ),
                      ),
                      if (schedule.isAuto) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('자동',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_fmtDate(schedule.date),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}
