import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/models/schedule_model.dart';
import '../../data/repositories/schedule_repository.dart';

class ScheduleController extends GetxController {
  final _repository = ScheduleRepository();

  final schedules = <ScheduleItem>[].obs;
  final isLoading = false.obs;
  final focusedDay = DateTime.now().obs;
  final selectedDay = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      schedules.value = await _repository.list();
    } catch (_) {
      AppSnackbar.error('일정을 불러오지 못했어요.');
    } finally {
      isLoading.value = false;
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<ScheduleItem> eventsOf(DateTime day) =>
      schedules.where((s) => _sameDay(s.date, day)).toList();

  List<ScheduleItem> get selectedSchedules => eventsOf(selectedDay.value);

  void selectDay(DateTime day, DateTime focused) {
    selectedDay.value = day;
    focusedDay.value = focused;
  }

  Future<void> createMany(String title, List<DateTime> dates) async {
    try {
      for (final d in dates) {
        await _repository.create(title, d);
      }
      await load();
      AppSnackbar.success('일정 ${dates.length}건을 추가했어요.');
    } catch (_) {
      AppSnackbar.error('일정을 추가하지 못했어요.');
    }
  }

  Future<void> edit(int id, String title, DateTime date) async {
    try {
      await _repository.update(id, title, date);
      await load();
      AppSnackbar.success('일정을 수정했어요.');
    } catch (_) {
      AppSnackbar.error('일정을 수정하지 못했어요.');
    }
  }

  Future<void> remove(int id) async {
    try {
      await _repository.remove(id);
      await load();
      AppSnackbar.success('일정을 삭제했어요.');
    } catch (_) {
      AppSnackbar.error('일정을 삭제하지 못했어요.');
    }
  }
}
