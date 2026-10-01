import '../../core/network/api_client.dart';
import '../models/company_model.dart';

class CompanyRepository {
  Future<List<CompanySummary>> search(String query) async {
    final res = await ApiClient.dio.get(
      '/companies/search',
      queryParameters: {'q': query},
    );
    final data = res.data as List;
    return data
        .map((e) => CompanySummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CompanyDetail> detail(String id) async {
    final res = await ApiClient.dio.get('/companies/$id');
    return CompanyDetail.fromJson(res.data as Map<String, dynamic>);
  }

  Future<int> reviewCount(String id) async {
    final res = await ApiClient.dio.get('/companies/$id/reviews');
    return (res.data as List).length;
  }
}
