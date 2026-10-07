import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/school_model.dart';
import '../../../data/repositories/school_repository.dart';
import 'signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              if (controller.step.value == 1) {
                controller.prevStep();
              } else {
                Get.back();
              }
            },
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Obx(
                      () => controller.step.value == 0
                          ? _accountStep()
                          : _profileStep(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBadge() {
    return Text(
      '${controller.step.value + 1} / 2',
      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _accountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _stepBadge(),
        const SizedBox(height: 8),
        Text('계정 만들고\n실습 준비 시작하기', style: AppTextStyles.title),
        const SizedBox(height: 30),
        _Field(
          label: '이메일',
          hint: '이메일을 입력해주세요',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 30),
        _Field(
          label: '비밀번호',
          hint: '비밀번호를 입력해주세요',
          controller: controller.passwordController,
          obscure: true,
        ),
        const SizedBox(height: 30),
        _Field(
          label: '비밀번호 확인',
          hint: '비밀번호를 한 번 더 입력해주세요',
          controller: controller.passwordConfirmController,
          obscure: true,
        ),
        const SizedBox(height: 40),
        const Spacer(),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('이미 계정이 있으신가요? ',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary)),
              GestureDetector(
                onTap: () => Get.back(),
                child: Text('로그인',
                    style: AppTextStyles.bodyStrong
                        .copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.nextStep,
            child: const Text('다음'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _profileStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _stepBadge(),
        const SizedBox(height: 8),
        Text('프로필을\n알려주세요', style: AppTextStyles.title),
        const SizedBox(height: 30),
        _Field(
          label: '이름',
          hint: '이름을 입력해주세요',
          controller: controller.nameController,
        ),
        const SizedBox(height: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('학교', style: AppTextStyles.bodyStrong),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showSchoolSearch(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final s = controller.school.value;
                        return Text(
                          s.isEmpty ? '학교를 검색해주세요' : s,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            color: s.isEmpty
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        );
                      }),
                    ),
                    const Icon(Icons.search,
                        size: 20, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        _Field(
          label: '학년',
          hint: '예: 3학년',
          controller: controller.gradeController,
        ),
        const SizedBox(height: 40),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isLoading.value ? null : controller.signup,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : const Text('가입하기'),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showSchoolSearch(BuildContext context) {
    final repository = SchoolRepository();
    final results = <School>[].obs;
    final loading = false.obs;
    final searched = false.obs;
    final searchController = TextEditingController();

    Future<void> run() async {
      final q = searchController.text.trim();
      if (q.isEmpty) {
        return;
      }
      FocusScope.of(context).unfocus();
      loading.value = true;
      searched.value = true;
      try {
        results.value = await repository.search(q);
      } catch (_) {
        results.clear();
      } finally {
        loading.value = false;
      }
    }

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('학교 검색', style: AppTextStyles.heading),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => run(),
                  decoration: InputDecoration(
                    hintText: '학교명을 입력해주세요',
                    hintStyle: AppTextStyles.body
                        .copyWith(color: AppColors.textDisabled),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    if (loading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      );
                    }
                    if (!searched.value) {
                      return Center(
                        child: Text('학교명으로 검색해보세요',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textDisabled)),
                      );
                    }
                    if (results.isEmpty) {
                      return Center(
                        child: Text('검색 결과가 없어요',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textDisabled)),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: results.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (_, i) {
                        final s = results[i];
                        return GestureDetector(
                          onTap: () {
                            controller.selectSchool(s.name);
                            Get.back();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: AppTextStyles.bodyStrong),
                                const SizedBox(height: 4),
                                Text(
                                  [s.region, s.kind]
                                      .whereType<String>()
                                      .where((e) => e.isNotEmpty)
                                      .join(' · '),
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyStrong),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }
}
