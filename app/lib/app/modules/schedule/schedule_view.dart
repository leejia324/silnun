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
            const SizedBox(height: 4),
            Obx(() {
              controller.schedules.length;
              final today = DateTime.now();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TableCalendar<ScheduleItem>(
                  locale: 'ko_KR',
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2100),
                  focusedDay: controller.focusedDay.value,
                  selectedDayPredicate: (d) =>
                      isSameDay(d, controller.selectedDay.value),
                  eventLoader: controller.eventsOf,
                  onDaySelected: controller.selectDay,
                  onPageChanged: (day) => controller.focusedDay.value = day,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: false,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                    titleTextStyle: AppTextStyles.bodyStrong,
                    headerPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  availableGestures: AvailableGestures.horizontalSwipe,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: AppTextStyles.caption
                        .copyWith(color: AppColors.textDisabled),
                    weekendStyle: AppTextStyles.caption
                        .copyWith(color: AppColors.textDisabled),
                  ),
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                  ),
                  calendarBuilders: CalendarBuilders<ScheduleItem>(
                    defaultBuilder: (context, day, _) => _dayCell(
                      day,
                      AppTextStyles.body,
                    ),
                    todayBuilder: (context, day, _) => _filledCircle(day),
                    selectedBuilder: (context, day, _) =>
                        isSameDay(day, today)
                            ? _filledCircle(day)
                            : _ringCircle(day),
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) {
                        return null;
                      }
                      if (isSameDay(day, today) ||
                          isSameDay(day, controller.selectedDay.value)) {
                        return const SizedBox.shrink();
                      }
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: Obx(() {
                final sel = controller.selectedDay.value;
                final items = controller.selectedSchedules;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: [
                    Text(
                      '${sel.month}월 ${sel.day}일 (${_weekdays[sel.weekday - 1]})',
                      style: AppTextStyles.bodyStrong,
                    ),
                    const SizedBox(height: 14),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                          child: Text('이 날짜에 일정이 없어요',
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.textDisabled)),
                        ),
                      )
                    else
                      ...items.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ScheduleCard(
                              schedule: s,
                              onTap: () => _showEditor(context, existing: s),
                              onDelete: () => controller.remove(s.id),
                            ),
                          )),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(DateTime day, TextStyle style) {
    return Center(child: Text('${day.day}', style: style));
  }

  Widget _filledCircle(DateTime day) {
    return Center(
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Text('${day.day}',
            style: AppTextStyles.body.copyWith(color: AppColors.surface)),
      ),
    );
  }

  Widget _ringCircle(DateTime day) {
    return Center(
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Text('${day.day}',
            style: AppTextStyles.body.copyWith(color: AppColors.primary)),
      ),
    );
  }

  void _showEditor(BuildContext context, {ScheduleItem? existing}) {
    final isEdit = existing != null;
    final titleController = TextEditingController(text: existing?.title ?? '');
    final focused = Rx<DateTime>(existing?.date ?? controller.selectedDay.value);
    final single = Rx<DateTime>(existing?.date ?? controller.selectedDay.value);
    final rangeStart = Rxn<DateTime>(controller.selectedDay.value);
    final rangeEnd = Rxn<DateTime>();

    List<DateTime> collectDates() {
      if (isEdit) {
        return [single.value];
      }
      final s = rangeStart.value;
      if (s == null) {
        return [];
      }
      final e = rangeEnd.value ?? s;
      final start = DateTime(s.year, s.month, s.day);
      final end = DateTime(e.year, e.month, e.day);
      final out = <DateTime>[];
      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        out.add(d);
      }
      return out;
    }

    final calendarStyle = CalendarStyle(
      outsideDaysVisible: false,
      todayDecoration: const BoxDecoration(
        color: AppColors.primarySurface,
        shape: BoxShape.circle,
      ),
      todayTextStyle: AppTextStyles.body.copyWith(color: AppColors.primary),
      selectedDecoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: AppTextStyles.body.copyWith(color: AppColors.surface),
      rangeStartDecoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      rangeEndDecoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      rangeStartTextStyle:
          AppTextStyles.body.copyWith(color: AppColors.surface),
      rangeEndTextStyle: AppTextStyles.body.copyWith(color: AppColors.surface),
      withinRangeTextStyle:
          AppTextStyles.body.copyWith(color: AppColors.primary),
      rangeHighlightColor: AppColors.primarySurface,
    );

    final headerStyle = HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      titleTextStyle: AppTextStyles.bodyStrong,
      leftChevronIcon:
          const Icon(Icons.chevron_left, color: AppColors.textSecondary),
      rightChevronIcon:
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
    final dowStyle = DaysOfWeekStyle(
      weekdayStyle: AppTextStyles.caption,
      weekendStyle: AppTextStyles.caption,
    );

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEdit ? '일정 수정' : '일정 추가',
                      style: AppTextStyles.heading),
                  if (isEdit)
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        controller.remove(existing.id);
                      },
                      child: Text('삭제',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.danger)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: '일정 제목'),
              ),
              const SizedBox(height: 8),
              if (!isEdit)
                Text('시작일과 종료일을 선택하면 기간이 모두 추가돼요',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Obx(
                () => isEdit
                    ? TableCalendar<void>(
                        locale: 'ko_KR',
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2100),
                        focusedDay: focused.value,
                        headerStyle: headerStyle,
                        daysOfWeekStyle: dowStyle,
                        calendarStyle: calendarStyle,
                        selectedDayPredicate: (d) =>
                            isSameDay(d, single.value),
                        onDaySelected: (sel, foc) {
                          single.value = sel;
                          focused.value = foc;
                        },
                      )
                    : TableCalendar<void>(
                        locale: 'ko_KR',
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2100),
                        focusedDay: focused.value,
                        headerStyle: headerStyle,
                        daysOfWeekStyle: dowStyle,
                        calendarStyle: calendarStyle,
                        rangeSelectionMode: RangeSelectionMode.toggledOn,
                        rangeStartDay: rangeStart.value,
                        rangeEndDay: rangeEnd.value,
                        onRangeSelected: (s, e, foc) {
                          rangeStart.value = s;
                          rangeEnd.value = e;
                          focused.value = foc;
                        },
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
                        final dates = collectDates();
                        if (title.isEmpty || dates.isEmpty) {
                          return;
                        }
                        Get.back();
                        if (isEdit) {
                          controller.edit(existing.id, title, dates.first);
                        } else {
                          controller.createMany(title, dates);
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

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

String _ddayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;
  if (diff == 0) {
    return 'D-DAY';
  }
  return diff > 0 ? 'D-$diff' : 'D+${-diff}';
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
                              horizontal: 7, vertical: 2),
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
                  Text(_ddayLabel(schedule.date),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.danger)),
                ],
              ),
            ),
            const SizedBox(width: 10),
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
