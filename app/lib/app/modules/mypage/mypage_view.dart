import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'mypage_controller.dart';

class MypageView extends GetView<MypageController> {
  const MypageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('마이페이지', style: AppTextStyles.title),
            const SizedBox(height: 20),
            Obx(() {
              final name = controller.displayName;
              final initial = name.length >= 2
                  ? name.substring(0, 2)
                  : (name.isNotEmpty ? name : '?');
              return Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(initial,
                        style: AppTextStyles.bodyStrong
                            .copyWith(color: AppColors.surface)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.heading),
                        const SizedBox(height: 4),
                        Text(
                          controller.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        value: '${controller.completedCount.value}',
                        label: '완료한 체크리스트',
                      ),
                    ),
                    Container(
                        width: 1, height: 36, color: AppColors.border),
                    Expanded(
                      child: _Stat(
                        value: '${controller.companyCount.value}',
                        label: '확인한 기업',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            _MenuRow(label: '체크리스트 기록', onTap: controller.openChecklists),
            _divider(),
            _MenuRow(label: '알림 설정', onTap: controller.comingSoon),
            _divider(),
            _MenuRow(label: '계정 정보', onTap: controller.comingSoon),
            _divider(),
            _MenuRow(label: '문의하기', onTap: controller.comingSoon),
            const SizedBox(height: 36),
            Center(
              child: GestureDetector(
                onTap: () => _confirmLogout(context),
                child: Text(
                  '로그아웃',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textDisabled),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.border);

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('로그아웃 하시겠습니까?', style: AppTextStyles.heading),
              const SizedBox(height: 10),
              Text(
                '다시 이용하려면 로그인이 필요합니다.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.textSecondary,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: AppTextStyles.button,
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.logout();
                      },
                      child: const Text('확인'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.title),
        const SizedBox(height: 4),
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.body)),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}
