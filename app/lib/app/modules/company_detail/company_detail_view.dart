import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/company_model.dart';
import 'company_detail_controller.dart';

class CompanyDetailView extends GetView<CompanyDetailController> {
  const CompanyDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final d = controller.detail.value;
        if (d == null) {
          return Center(
            child: Text(
              '정보를 불러올 수 없어요',
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(d),
              const SizedBox(height: 28),
              _summary(d),
              _divider(),
              _violationSection(d),
              _divider(),
              _laborSection(d),
              _divider(),
              _reviewSection(),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            width: double.infinity,
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isStarting.value ? null : controller.startChecklist,
                child: controller.isStarting.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      )
                    : const Text('체크리스트 시작하기'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Divider(height: 1, color: AppColors.border),
      );

  Widget _header(CompanyDetail d) {
    final color = AppColors.riskColor(d.riskLevel);
    final status = d.riskLevel == 'no_data'
        ? '정보 없음'
        : d.riskLevel == 'good'
            ? '양호'
            : '확인 필요';
    final meta = [d.category, d.region, d.employeeSizeBand]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                d.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.display,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(status,
                style: AppTextStyles.bodyStrong.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Text(meta,
            style:
                AppTextStyles.body.copyWith(color: AppColors.textDisabled)),
      ],
    );
  }

  Widget _summary(CompanyDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('종합 확인 결과',
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppColors.riskLabel(d.riskLevel) +
                  (d.riskLevel == 'danger' || d.riskLevel == 'caution'
                      ? ' 단계'
                      : ''),
              style: AppTextStyles.display
                  .copyWith(color: AppColors.riskColor(d.riskLevel)),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                d.riskLevel == 'no_data'
                    ? '공시 정보 없음'
                    : '확인 필요 항목 ${d.violations.length}건',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        if (d.riskLevel != 'no_data') ...[
          const SizedBox(height: 16),
          _RiskStepper(level: d.riskLevel),
        ],
      ],
    );
  }

  Widget _violationSection(CompanyDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('연도별 위반 이력', style: AppTextStyles.heading),
            Text('${d.violations.length}건', style: AppTextStyles.heading),
          ],
        ),
        const SizedBox(height: 20),
        _ViolationChart(violations: d.violations, endYear: d.reportYear),
        const SizedBox(height: 20),
        if (_violationSummary(d).isNotEmpty)
          Text(_violationSummary(d), style: AppTextStyles.body),
        const SizedBox(height: 6),
        Text(
          '${d.seriousCasualtyCount != null && d.seriousCasualtyCount! > 0 ? '중대재해 ${d.seriousCasualtyCount}명' : '중대재해 없음'}'
          '${d.reportYear != null ? ' · 최근 공시 ${d.reportYear}' : ''}',
          style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
        ),
      ],
    );
  }

  String _violationSummary(CompanyDetail d) {
    final desc = d.violations
        .map((v) => v.description)
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    return desc.join(' · ');
  }

  Widget _laborSection(CompanyDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('근로 조건 확인', style: AppTextStyles.heading),
        const SizedBox(height: 16),
        if (d.laborConditions.isEmpty)
          Text('등록된 정보가 없어요',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary))
        else
          ...d.laborConditions.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(
                    c.compliant ? Icons.check : Icons.close,
                    size: 20,
                    color: c.compliant ? AppColors.primary : AppColors.danger,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    c.compliant ? '${c.label} 준수' : '${c.label} 위반 이력',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _reviewSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('이전 실습생 후기', style: AppTextStyles.heading),
        Obx(
          () => Text(
            '${controller.reviewCount.value}명 참여',
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _RiskStepper extends StatelessWidget {
  const _RiskStepper({required this.level});

  final String level;

  static const _steps = ['good', 'caution', 'danger'];
  static const _labels = ['양호', '주의', '위험'];

  @override
  Widget build(BuildContext context) {
    final activeIndex = _steps.indexOf(level);
    return Column(
      children: [
        Row(
          children: List.generate(3, (i) {
            final active = i == activeIndex;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.riskColor(_steps[i])
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (i) {
            final active = i == activeIndex;
            return Expanded(
              child: Text(
                _labels[i],
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: active
                      ? AppColors.riskColor(_steps[i])
                      : AppColors.textDisabled,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ViolationChart extends StatelessWidget {
  const _ViolationChart({required this.violations, required this.endYear});

  final List<ViolationItem> violations;
  final int? endYear;

  @override
  Widget build(BuildContext context) {
    final last = endYear ??
        (violations.isNotEmpty
            ? violations.map((v) => v.year).reduce((a, b) => a > b ? a : b)
            : DateTime.now().year);
    final years = [for (var y = last - 3; y <= last; y++) y];
    final counts = {
      for (final y in years)
        y: violations
            .where((v) => v.year == y)
            .fold<int>(0, (s, v) => s + v.count),
    };
    final maxCount = counts.values.fold<int>(0, (m, c) => c > m ? c : m);

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: years.map((y) {
          final count = counts[y] ?? 0;
          final ratio = maxCount == 0 ? 0.0 : count / maxCount;
          final barHeight = count == 0 ? 6.0 : 20 + ratio * 70;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 34,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: count == 0 ? AppColors.border : AppColors.primary,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$y',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textDisabled),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
