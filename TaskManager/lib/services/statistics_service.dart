export 'stats_service.dart';

import '../models/task_stats.dart';
import 'api_client.dart';
import 'stats_service.dart';

class StatisticsService {
  StatisticsService._();
  static final StatisticsService instance = StatisticsService._();

  final ApiClient _client = ApiClient.instance;
  final StatsService _statsService = StatsService.instance;

  /// Lấy thống kê công việc và hiệu suất (E1)
  Future<TaskStatsData> getTaskStats({
    String timeRange = 'all',
    String scope = 'all',
  }) {
    return _statsService.getTaskStats(timeRange: timeRange, scope: scope);
  }

  /// Thống kê chi tiết công việc qua endpoint chuẩn /api/statistics/tasks
  Future<TaskStatsData> getStatisticsTasks({
    String timeRange = 'all',
    String scope = 'all',
  }) async {
    final queryParams = <String, dynamic>{
      'timeRange': timeRange,
      'scope': scope,
    };

    final response = await _client.get(
      '/statistics/tasks',
      queryParameters: queryParams,
    );

    final data = response['data'] as Map<String, dynamic>;
    return TaskStatsData.fromJson(data);
  }

  /// Thống kê phân công qua endpoint /api/statistics/assignments
  Future<Map<String, dynamic>> getAssignmentStats({
    String timeRange = 'all',
    String scope = 'all',
  }) async {
    final response = await _client.get(
      '/statistics/assignments',
      queryParameters: {'timeRange': timeRange, 'scope': scope},
    );
    return response['data'] as Map<String, dynamic>;
  }

  /// Thống kê hạn chót qua endpoint /api/statistics/deadlines
  Future<Map<String, dynamic>> getDeadlineStats({
    String timeRange = 'all',
  }) async {
    final response = await _client.get(
      '/statistics/deadlines',
      queryParameters: {'timeRange': timeRange},
    );
    return response['data'] as Map<String, dynamic>;
  }
}
