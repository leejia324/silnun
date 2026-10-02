import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/models/checklist_model.dart';
import '../../data/repositories/checklist_repository.dart';
import '../checklist_list/checklist_list_controller.dart';

class ChecklistDetailController extends GetxController {
  final _repository = ChecklistRepository();

  final checklist = Rxn<Checklist>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments;
    if (id is int) {
      load(id);
    }
  }

  Future<void> load(int id) async {
    isLoading.value = true;
    try {
      checklist.value = await _repository.detail(id);
    } catch (_) {
      AppSnackbar.error('체크리스트를 불러오지 못했어요.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggle(ChecklistItem item) async {
    final current = checklist.value;
    if (current == null) {
      return;
    }
    try {
      checklist.value =
          await _repository.toggleItem(current.id, item.id, !item.checked);
      _refreshList();
    } catch (_) {
      AppSnackbar.error('항목을 변경하지 못했어요.');
    }
  }

  Future<void> submit() async {
    final current = checklist.value;
    if (current == null) {
      return;
    }
    isSubmitting.value = true;
    try {
      checklist.value = await _repository.submit(current.id);
      _refreshList();
      AppSnackbar.success('체크리스트를 제출했어요.');
    } catch (_) {
      AppSnackbar.error('제출하지 못했어요.');
    } finally {
      isSubmitting.value = false;
    }
  }

  void _refreshList() {
    if (Get.isRegistered<ChecklistListController>()) {
      Get.find<ChecklistListController>().load();
    }
  }
}
