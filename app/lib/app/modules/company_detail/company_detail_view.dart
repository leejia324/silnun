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
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.name, style: AppTextStyles.title),
              const SizedBox(height: 8),
              _metaLine(d),
              const SizedBox(height: 20),
              if (d.riskLevel == 'danger') ...[
                _DangerBanner(count: d.seriousCasualtyCount ?? 0),
                const SizedBox(height: 16),
              ],
              _SummaryCard(detail: d),
              const SizedBox(height: 28),
              _ViolationSection(violations: d.violations),
              const SizedBox(height: 28),
              _LaborSection(conditions: d.laborConditions),
            ],
          ),
        );
      }),
    );
  }

  Widget _metaLine(CompanyDetail d) {
    final parts = [d.region, d.category, d.employeeSizeBand]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    return Text(
      parts.join(' · '),
      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _DangerBanner extends StatelessWidget {
  const _DangerBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.dangerStrong),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count > 0
                  ? '중대재해가 $count명 발생한 사업장이에요'
                  : '중대재해가 발생한 사업장이에요',
              style: AppTextStyles.bodyStrong
                  .copyWith(color: AppColors.dangerStrong),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.detail});

  final CompanyDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('종합 확인 결과', style: AppTextStyles.bodyStrong),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.riskSurface(detail.riskLevel),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  AppColors.riskLabel(detail.riskLevel),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.riskColor(detail.riskLevel),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (detail.injuryRate != null) ...[
            const SizedBox(height: 16),
            _rateRow('재해율', detail.injuryRate!, AppColors.danger),
            const SizedBox(height: 10),
            if (detail.avgInjuryRate != null)
              _rateRow('동종업종 평균', detail.avgInjuryRate!,
                  AppColors.textSecondary),
          ],
          if (detail.injuryRate == null && detail.riskLevel == 'no_data') ...[
            const SizedBox(height: 12),
            Text(
              '공시된 산업재해 정보가 없어요',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rateRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary)),
        Text('${value.toStringAsFixed(2)}%',
            style: AppTextStyles.bodyStrong.copyWith(color: color)),
      ],
    );
  }
}

class _ViolationSection extends StatelessWidget {
  const _ViolationSection({required this.violations});

  final List<ViolationItem> violations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('연도별 위반 이력', style: AppTextStyles.heading),
        const SizedBox(height: 12),
        if (violations.isEmpty)
          Text(
            '위반 이력이 없어요',
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          )
        else
          ...violations.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${v.year}',
                      style: AppTextStyles.bodyStrong
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      v.description ?? '재해 ${v.count}건',
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _LaborSection extends StatelessWidget {
  const _LaborSection({required this.conditions});

  final List<LaborConditionItem> conditions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('안전·근로 조건', style: AppTextStyles.heading),
        const SizedBox(height: 12),
        if (conditions.isEmpty)
          Text(
            '등록된 정보가 없어요',
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          )
        else
          ...conditions.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    c.compliant
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 20,
                    color: c.compliant ? AppColors.good : AppColors.danger,
                  ),
                  const SizedBox(width: 10),
                  Text('${c.label} ${c.compliant ? '준수' : '위반'}',
                      style: AppTextStyles.body),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
