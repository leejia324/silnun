import '../../core/network/api_client.dart';
import '../models/checklist_model.dart';

class ChecklistRepository {
  Future<List<Checklist>> list() async {
    final res = await ApiClient.dio.get('/checklists');
    return (res.data as List)
        .map((e) => Checklist.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Checklist> create(String companyId) async {
    final res = await ApiClient.dio.post(
      '/checklists',
      data: {'company_id': companyId},
    );
    return Checklist.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Checklist> detail(int id) async {
    final res = await ApiClient.dio.get('/checklists/$id');
    return Checklist.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Checklist> toggleItem(int id, int itemId, bool checked) async {
    final res = await ApiClient.dio.patch(
      '/checklists/$id/items/$itemId',
      data: {'checked': checked},
    );
    return Checklist.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Checklist> submit(int id) async {
    final res = await ApiClient.dio.post('/checklists/$id/submit');
    return Checklist.fromJson(res.data as Map<String, dynamic>);
  }
}
