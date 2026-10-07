import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

class SignupController extends GetxController {
  final _userRepository = UserRepository();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final nameController = TextEditingController();
  final schoolController = TextEditingController();
  final gradeController = TextEditingController();
  final isLoading = false.obs;
  final step = 0.obs;

  void nextStep() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = passwordConfirmController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      AppSnackbar.info('모든 항목을 입력해주세요.');
      return;
    }
    if (password != confirm) {
      AppSnackbar.info('비밀번호가 일치하지 않습니다.');
      return;
    }
    step.value = 1;
  }

  void prevStep() => step.value = 0;

  Future<void> signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final name = nameController.text.trim();
    final school = schoolController.text.trim();
    final grade = gradeController.text.trim();

    if (name.isEmpty || school.isEmpty || grade.isEmpty) {
      AppSnackbar.info('모든 항목을 입력해주세요.');
      return;
    }

    isLoading.value = true;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _userRepository.updateProfile(
        email: email,
        name: name,
        school: school,
        grade: grade,
      );
      Get.offAllNamed(Routes.home);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_messageFor(e.code));
    } finally {
      isLoading.value = false;
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '이미 가입된 이메일입니다.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'weak-password':
        return '비밀번호는 6자 이상이어야 합니다.';
      default:
        return '회원가입 중 오류가 발생했습니다.';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    nameController.dispose();
    schoolController.dispose();
    gradeController.dispose();
    super.onClose();
  }
}
