import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../routes/app_routes.dart';

class MypageController extends GetxController {
  final _checklistRepository = ChecklistRepository();
  final _userRepository = UserRepository();

  final completedCount = 0.obs;
  final companyCount = 0.obs;
  final name = ''.obs;
  final school = ''.obs;
  final grade = ''.obs;

  String get email => FirebaseAuth.instance.currentUser?.email ?? '';

  String get displayName {
    if (name.value.isNotEmpty) {
      return name.value;
    }
    if (email.isEmpty) {
      return '실습생';
    }
    return email.split('@').first;
  }

  String get subtitle {
    final parts = [school.value, grade.value]
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? email : parts.join(' ');
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      final profile = await _userRepository.me();
      name.value = profile.name ?? '';
      school.value = profile.school ?? '';
      grade.value = profile.grade ?? '';
    } catch (_) {}
    try {
      final list = await _checklistRepository.list();
      companyCount.value = list.length;
      completedCount.value = list.where((c) => c.isCompleted).length;
    } catch (_) {}
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
