import '../../core/network/api_client.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  Future<List<ScheduleItem>> list() async {
    final res = await ApiClient.dio.get('/schedules');
    return (res.data as List)
        .map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ScheduleItem> create(String title, DateTime date) async {
    final res = await ApiClient.dio.post(
      '/schedules',
      data: {'title': title, 'date': _fmt(date)},
    );
    return ScheduleItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ScheduleItem> update(int id, String title, DateTime date) async {
    final res = await ApiClient.dio.patch(
      '/schedules/$id',
      data: {'title': title, 'date': _fmt(date)},
    );
    return ScheduleItem.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> remove(int id) async {
    await ApiClient.dio.delete('/schedules/$id');
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
