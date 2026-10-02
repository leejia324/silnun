import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/company_model.dart';
import 'search_controller.dart';

class SearchView extends GetView<CompanySearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('기업 검색', style: AppTextStyles.title),
              const SizedBox(height: 16),
              TextField(
                controller: controller.queryController,
                focusNode: controller.focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => controller.search(),
                decoration: InputDecoration(
                  hintText: '기업명을 검색해보세요',
                  hintStyle: AppTextStyles.body
                      .copyWith(color: AppColors.textDisabled),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: Obx(
                    () => controller.queryText.value.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: const Icon(Icons.cancel,
                                color: AppColors.textDisabled, size: 20),
                            onPressed: controller.clear,
                          ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: Obx(_buildBody)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (controller.isFocused.value && controller.recentSearches.isNotEmpty) {
      return _recentSearches();
    }
    if (controller.hasSearched.value) {
      if (controller.results.isEmpty) {
        return _emptyResult();
      }
      return ListView.separated(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: controller.results.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (_, i) => _CompanyCard(
          company: controller.results[i],
          onTap: () => controller.openCompany(controller.results[i].id),
        ),
      );
    }
    if (controller.recentSearches.isEmpty) {
      return _firstVisitGuide();
    }
    return _recentSearches();
  }

  Widget _recentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('최근 검색', style: AppTextStyles.bodyStrong),
            GestureDetector(
              onTap: controller.clearRecents,
              child: Text(
                '전체 삭제',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.recentSearches
              .map(
                (term) => _RecentChip(
                  label: term,
                  onTap: () => controller.selectRecent(term),
                  onRemove: () => controller.removeRecent(term),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _firstVisitGuide() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('실습처를 검색해보세요', style: AppTextStyles.heading),
          const SizedBox(height: 8),
          Text(
            '안전 이력을 확인하거나\n정확한 명칭으로 검색해보세요',
            textAlign: TextAlign.center,
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _emptyResult() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sentiment_dissatisfied_outlined,
              size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('검색 결과가 없어요', style: AppTextStyles.heading),
          const SizedBox(height: 8),
          Text(
            '다른 검색어로 다시 시도해보세요',
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company, required this.onTap});

  final CompanySummary company;
  final VoidCallback onTap;

  String get _statusLabel {
    switch (company.riskLevel) {
      case 'no_data':
        return '정보 없음';
      case 'good':
        return '양호';
      default:
        return '확인 필요';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(company.riskLevel);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          company.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.heading,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 6,
                        height: 6,
                        decoration:
                            BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusLabel,
                        style: AppTextStyles.bodyStrong.copyWith(color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [company.category, company.region]
                        .whereType<String>()
                        .where((e) => e.isNotEmpty)
                        .join('   '),
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textDisabled),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppColors.textDisabled, size: 24),
          ],
        ),
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close,
                  size: 16, color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}
