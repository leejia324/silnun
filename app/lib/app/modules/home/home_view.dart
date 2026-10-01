import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    ChecklistListView(),
    SearchView(),
    DashboardView(),
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
            items: [
              BottomNavigationBarItem(
                icon: _navIcon('check.svg', false),
                activeIcon: _navIcon('check fill.svg', true),
                label: '체크리스트',
              ),
              BottomNavigationBarItem(
                icon: _navIcon('search.svg', false),
                activeIcon: _navIcon('search.svg', true),
                label: '검색',
              ),
              BottomNavigationBarItem(
                icon: _navIcon('home.svg', false),
                activeIcon: _navIcon('home fill.svg', true),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: _navIcon('calendar.svg', false),
                activeIcon: _navIcon('calendar.svg', true),
                label: '일정',
              ),
              BottomNavigationBarItem(
                icon: _navIcon('my.svg', false),
                activeIcon: _navIcon('my.svg', true),
                label: '마이페이지',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(String name, bool active) {
    return SvgPicture.asset(
      'assets/svg/bottom icon/$name',
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        active ? AppColors.primary : AppColors.textDisabled,
        BlendMode.srcIn,
      ),
    );
  }
}
