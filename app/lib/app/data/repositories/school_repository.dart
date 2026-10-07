import 'package:dio/dio.dart';

import '../models/school_model.dart';

class SchoolRepository {
  final Dio _dio = Dio();

  Future<List<School>> search(String query) async {
    final res = await _dio.get(
      'https://open.neis.go.kr/hub/schoolInfo',
      queryParameters: {
        'Type': 'json',
        'pIndex': 1,
        'pSize': 30,
        'SCHUL_NM': query,
      },
    );
    final data = res.data;
    if (data is! Map || !data.containsKey('schoolInfo')) {
      return [];
    }
    final blocks = data['schoolInfo'] as List;
    final rows = blocks
        .whereType<Map>()
        .firstWhere((b) => b.containsKey('row'), orElse: () => {})['row'];
    if (rows is! List) {
      return [];
    }
    return rows
        .map((e) => School.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
