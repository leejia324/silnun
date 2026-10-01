import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.info('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    isLoading.value = true;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
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
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'too-many-requests':
        return '잠시 후 다시 시도해주세요.';
      default:
        return '로그인 중 오류가 발생했습니다.';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
