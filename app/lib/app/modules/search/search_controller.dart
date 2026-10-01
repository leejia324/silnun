import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/models/company_model.dart';
import '../../data/repositories/company_repository.dart';
import '../../routes/app_routes.dart';

class CompanySearchController extends GetxController {
  final _repository = CompanyRepository();
  final queryController = TextEditingController();

  final results = <CompanySummary>[].obs;
  final recentSearches = <String>[].obs;
  final isLoading = false.obs;
  final hasSearched = false.obs;

  Future<void> search([String? term]) async {
    final query = (term ?? queryController.text).trim();
    if (query.isEmpty) {
      AppSnackbar.info('검색어를 입력해주세요.');
      return;
    }
    queryController.text = query;
    _addRecent(query);

    isLoading.value = true;
    hasSearched.value = true;
    try {
      results.value = await _repository.search(query);
    } catch (_) {
      results.clear();
      AppSnackbar.error('검색 중 오류가 발생했어요.');
    } finally {
      isLoading.value = false;
    }
  }

  void selectRecent(String term) {
    queryController.text = term;
    search(term);
  }

  void removeRecent(String term) => recentSearches.remove(term);

  void clearRecents() => recentSearches.clear();

  void openCompany(String id) =>
      Get.toNamed(Routes.companyDetail, arguments: id);

  void _addRecent(String query) {
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }
  }

  @override
  void onClose() {
    queryController.dispose();
    super.onClose();
  }
}
