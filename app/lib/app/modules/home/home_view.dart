import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../checklist_list/checklist_list_view.dart';
import '../dashboard/dashboard_view.dart';
import '../mypage/mypage_view.dart';
import '../schedule/schedule_view.dart';
import '../search/search_view.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const _tabs = [
    DashboardView(),
    SearchView(),
    ChecklistListView(),
    ScheduleView(),
    MypageView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: '검색',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fact_check_outlined),
                activeIcon: Icon(Icons.fact_check),
                label: '체크리스트',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: '일정',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '마이페이지',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
