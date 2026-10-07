import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../routes/app_routes.dart';
import '../home/home_controller.dart';

class MypageController extends GetxController {
  final _checklistRepository = ChecklistRepository();

  final completedCount = 0.obs;
  final companyCount = 0.obs;

  String get email => FirebaseAuth.instance.currentUser?.email ?? '';

  String get displayName {
    if (email.isEmpty) {
      return '실습생';
    }
    return email.split('@').first;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      final list = await _checklistRepository.list();
      companyCount.value = list.length;
      completedCount.value = list.where((c) => c.isCompleted).length;
    } catch (_) {}
  }

  void openChecklists() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().changeTab(0);
    }
  }

  void comingSoon() => AppSnackbar.info('준비 중인 기능이에요.');

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(Routes.onboarding);
    } catch (_) {
      AppSnackbar.error('로그아웃하지 못했어요.');
    }
  }
}
