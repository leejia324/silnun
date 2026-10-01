import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  String get displayName {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) {
      return '실습생';
    }
    return email.split('@').first;
  }
}
