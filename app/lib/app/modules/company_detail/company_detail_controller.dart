import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/models/company_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../data/repositories/company_repository.dart';
import '../../routes/app_routes.dart';
import '../checklist_list/checklist_list_controller.dart';

class CompanyDetailController extends GetxController {
  final _repository = CompanyRepository();
  final _checklistRepository = ChecklistRepository();

  final detail = Rxn<CompanyDetail>();
  final reviews = <Review>[].obs;
  final isLoading = false.obs;
  final isStarting = false.obs;
  final isPostingReview = false.obs;

  String _companyId = '';

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments;
    if (id is String) {
      _companyId = id;
      load(id);
    }
  }

  Future<void> load(String id) async {
    isLoading.value = true;
    try {
      detail.value = await _repository.detail(id);
      reviews.value = await _repository.reviews(id);
    } catch (_) {
      AppSnackbar.error('기업 정보를 불러오지 못했어요.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addReview(String content) async {
    if (_companyId.isEmpty) {
      return;
    }
    isPostingReview.value = true;
    try {
      await _repository.createReview(_companyId, content);
      reviews.value = await _repository.reviews(_companyId);
      AppSnackbar.success('후기를 등록했어요.');
    } catch (_) {
      AppSnackbar.error('후기를 등록하지 못했어요.');
    } finally {
      isPostingReview.value = false;
    }
  }

  Future<void> startChecklist() async {
    final company = detail.value;
    if (company == null) {
      return;
    }
    isStarting.value = true;
    try {
      final checklist = await _checklistRepository.create(company.id);
      if (Get.isRegistered<ChecklistListController>()) {
        Get.find<ChecklistListController>().load();
      }
      Get.toNamed(Routes.checklistDetail, arguments: checklist.id);
    } catch (_) {
      AppSnackbar.error('체크리스트를 시작하지 못했어요.');
    } finally {
      isStarting.value = false;
    }
  }
}
