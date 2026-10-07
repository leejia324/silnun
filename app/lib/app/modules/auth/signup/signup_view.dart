import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
                          : _profileStep(),
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

  Widget _profileStep() {
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
        _Field(
          label: '학교',
          hint: '학교명을 입력해주세요',
          controller: controller.schoolController,
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
