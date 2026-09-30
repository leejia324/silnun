import 'package:get/get.dart';

import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/signup/signup_binding.dart';
import '../modules/auth/signup/signup_view.dart';
import '../modules/checklist_detail/checklist_detail_binding.dart';
import '../modules/checklist_detail/checklist_detail_view.dart';
import '../modules/checklist_list/checklist_list_binding.dart';
import '../modules/checklist_list/checklist_list_view.dart';
import '../modules/company_detail/company_detail_binding.dart';
import '../modules/company_detail/company_detail_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/mypage/mypage_binding.dart';
import '../modules/mypage/mypage_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/schedule/schedule_binding.dart';
import '../modules/schedule/schedule_view.dart';
import '../modules/search/search_binding.dart';
import '../modules/search/search_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: Routes.companyDetail,
      page: () => const CompanyDetailView(),
      binding: CompanyDetailBinding(),
    ),
    GetPage(
      name: Routes.checklistList,
      page: () => const ChecklistListView(),
      binding: ChecklistListBinding(),
    ),
    GetPage(
      name: Routes.checklistDetail,
      page: () => const ChecklistDetailView(),
      binding: ChecklistDetailBinding(),
    ),
    GetPage(
      name: Routes.schedule,
      page: () => const ScheduleView(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: Routes.mypage,
      page: () => const MypageView(),
      binding: MypageBinding(),
    ),
  ];
}
