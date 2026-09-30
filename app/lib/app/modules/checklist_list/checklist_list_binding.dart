import 'package:get/get.dart';

import 'checklist_list_controller.dart';

class ChecklistListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChecklistListController>(() => ChecklistListController());
  }
}
