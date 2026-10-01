import 'package:get/get.dart';

import '../checklist_list/checklist_list_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../mypage/mypage_controller.dart';
import '../schedule/schedule_controller.dart';
import '../search/search_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<CompanySearchController>(() => CompanySearchController());
    Get.lazyPut<ChecklistListController>(() => ChecklistListController());
    Get.lazyPut<ScheduleController>(() => ScheduleController());
    Get.lazyPut<MypageController>(() => MypageController());
  }
}
