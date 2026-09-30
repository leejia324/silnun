import 'package:get/get.dart';

import 'checklist_detail_controller.dart';

class ChecklistDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChecklistDetailController>(() => ChecklistDetailController());
  }
}
