import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/models/company_model.dart';
import '../../data/repositories/company_repository.dart';

class CompanyDetailController extends GetxController {
  final _repository = CompanyRepository();

  final detail = Rxn<CompanyDetail>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments;
    if (id is String) {
      load(id);
    }
  }

  Future<void> load(String id) async {
    isLoading.value = true;
    try {
      detail.value = await _repository.detail(id);
    } catch (_) {
      AppSnackbar.error('기업 정보를 불러오지 못했어요.');
    } finally {
      isLoading.value = false;
    }
  }
}
