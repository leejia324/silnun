import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/models/checklist_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../routes/app_routes.dart';
import '../home/home_controller.dart';

class DashboardController extends GetxController {
  final _checklistRepository = ChecklistRepository();
  final _scheduleRepository = ScheduleRepository();
  final _userRepository = UserRepository();

  final name = ''.obs;
  final inProgress = <Checklist>[].obs;
  final upcoming = <ScheduleItem>[].obs;
  final isLoading = false.obs;

  String get displayName {
    if (name.value.isNotEmpty) {
      return name.value;
    }
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return email.isEmpty ? '실습생' : email.split('@').first;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final profile = await _userRepository.me();
      name.value = profile.name ?? '';
    } catch (_) {}
    try {
      final checklists = await _checklistRepository.list();
      inProgress.value =
          checklists.where((c) => !c.isCompleted).toList();
    } catch (_) {}
    try {
      final schedules = await _scheduleRepository.list();
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final future = schedules
          .where((s) => !s.date.isBefore(start))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      upcoming.value = future.take(3).toList();
    } catch (_) {}
    isLoading.value = false;
  }

  void goSchedule() => Get.find<HomeController>().changeTab(3);

  void openChecklist(int id) =>
      Get.toNamed(Routes.checklistDetail, arguments: id);
}
