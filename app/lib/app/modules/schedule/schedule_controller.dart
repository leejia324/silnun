import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/models/schedule_model.dart';
import '../../data/repositories/schedule_repository.dart';

class ScheduleController extends GetxController {
  final _repository = ScheduleRepository();

  final schedules = <ScheduleItem>[].obs;
  final isLoading = false.obs;

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

  Future<void> create(String title, DateTime date) async {
    try {
      await _repository.create(title, date);
      await load();
      AppSnackbar.success('일정을 추가했어요.');
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
