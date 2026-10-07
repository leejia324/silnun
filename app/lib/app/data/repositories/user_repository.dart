import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  Future<AppUser> me() async {
    final res = await ApiClient.dio.get('/users/me');
    return AppUser.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AppUser> updateProfile({
    String? email,
    String? name,
    String? school,
    String? grade,
  }) async {
    final res = await ApiClient.dio.patch(
      '/users/me',
      data: {
        'email': ?email,
        'name': ?name,
        'school': ?school,
        'grade': ?grade,
      },
    );
    return AppUser.fromJson(res.data as Map<String, dynamic>);
  }
}
