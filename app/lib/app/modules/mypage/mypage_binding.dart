import 'package:get/get.dart';

import 'mypage_controller.dart';

class MypageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MypageController>(() => MypageController());
  }
}
