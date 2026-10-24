import '../models/task_stats.dart';
import 'api_client.dart';

class StatsService {
  StatsService._();
  static final StatsService instance = StatsService._();

  final ApiClient _client = ApiClient.instance;

  /// Lấy số liệu thống kê công việc và hiệu suất (E1/E2)
  Future<TaskStatsData> getTaskStats({
    String timeRange = 'all',
    String scope = 'all',
  }) async {
    final queryParams = <String, dynamic>{
      'timeRange': timeRange,
      'scope': scope,
    };

    final response = await _client.get(
      '/tasks/stats/summary',
      queryParameters: queryParams,
    );

    final data = response['data'] as Map<String, dynamic>;
    return TaskStatsData.fromJson(data);
  }
}
