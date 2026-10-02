import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/models/checklist_model.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../routes/app_routes.dart';

class ChecklistListController extends GetxController {
  final _repository = ChecklistRepository();

  final checklists = <Checklist>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      checklists.value = await _repository.list();
    } catch (_) {
      AppSnackbar.error('체크리스트를 불러오지 못했어요.');
    } finally {
      isLoading.value = false;
    }
  }

  void openDetail(int id) => Get.toNamed(Routes.checklistDetail, arguments: id);
}
