import 'user.dart';

class CountPercentage {
  final int count;
  final int percentage;

  CountPercentage({required this.count, required this.percentage});

  factory CountPercentage.fromJson(Map<String, dynamic> json) {
    return CountPercentage(
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class TaskStatsSummary {
  final int totalTasks;
  final int completionRate;
  final int completedOnTimeRate;

  TaskStatsSummary({
    required this.totalTasks,
    required this.completionRate,
    required this.completedOnTimeRate,
  });

  factory TaskStatsSummary.fromJson(Map<String, dynamic> json) {
    return TaskStatsSummary(
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toInt() ?? 0,
      completedOnTimeRate: (json['completedOnTimeRate'] as num?)?.toInt() ?? 0,
    );
  }
}

class TaskStatusBreakdown {
  final CountPercentage todo;
  final CountPercentage inProgress;
  final CountPercentage completed;
  final CountPercentage cancelled;

  TaskStatusBreakdown({
    required this.todo,
    required this.inProgress,
    required this.completed,
    required this.cancelled,
  });

  factory TaskStatusBreakdown.fromJson(Map<String, dynamic> json) {
    return TaskStatusBreakdown(
      todo: CountPercentage.fromJson(json['todo'] ?? {}),
      inProgress: CountPercentage.fromJson(json['inProgress'] ?? {}),
      completed: CountPercentage.fromJson(json['completed'] ?? {}),
      cancelled: CountPercentage.fromJson(json['cancelled'] ?? {}),
    );
  }
}

class TaskPriorityBreakdown {
  final CountPercentage high;
  final CountPercentage medium;
  final CountPercentage low;

  TaskPriorityBreakdown({
    required this.high,
    required this.medium,
    required this.low,
  });

  factory TaskPriorityBreakdown.fromJson(Map<String, dynamic> json) {
    return TaskPriorityBreakdown(
      high: CountPercentage.fromJson(json['high'] ?? {}),
      medium: CountPercentage.fromJson(json['medium'] ?? {}),
      low: CountPercentage.fromJson(json['low'] ?? {}),
    );
  }
}

class TaskDeadlinesBreakdown {
  final int overdue;
  final int dueSoon;
  final int completedOnTime;

  TaskDeadlinesBreakdown({
    required this.overdue,
    required this.dueSoon,
    required this.completedOnTime,
  });

  factory TaskDeadlinesBreakdown.fromJson(Map<String, dynamic> json) {
    return TaskDeadlinesBreakdown(
      overdue: (json['overdue'] as num?)?.toInt() ?? 0,
      dueSoon: (json['dueSoon'] as num?)?.toInt() ?? 0,
      completedOnTime: (json['completedOnTime'] as num?)?.toInt() ?? 0,
    );
  }
}

class TaskMemberWorkload {
  final User user;
  final int taskCount;
  final int completedCount;

  TaskMemberWorkload({
    required this.user,
    required this.taskCount,
    required this.completedCount,
  });

  factory TaskMemberWorkload.fromJson(Map<String, dynamic> json) {
    return TaskMemberWorkload(
      user: User.fromJson(json['user'] ?? {}),
      taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class TaskStatsData {
  final String timeRange;
  final String scope;
  final TaskStatsSummary summary;
  final TaskStatusBreakdown byStatus;
  final TaskPriorityBreakdown byPriority;
  final TaskDeadlinesBreakdown deadlines;
  final List<TaskMemberWorkload> memberWorkloads;

  TaskStatsData({
    required this.timeRange,
    required this.scope,
    required this.summary,
    required this.byStatus,
    required this.byPriority,
    required this.deadlines,
    required this.memberWorkloads,
  });

  factory TaskStatsData.fromJson(Map<String, dynamic> json) {
    final memberList = (json['memberWorkloads'] as List<dynamic>? ?? [])
        .map((m) => TaskMemberWorkload.fromJson(m as Map<String, dynamic>))
        .toList();

    return TaskStatsData(
      timeRange: json['timeRange'] ?? 'all',
      scope: json['scope'] ?? 'all',
      summary: TaskStatsSummary.fromJson(json['summary'] ?? {}),
      byStatus: TaskStatusBreakdown.fromJson(json['byStatus'] ?? {}),
      byPriority: TaskPriorityBreakdown.fromJson(json['byPriority'] ?? {}),
      deadlines: TaskDeadlinesBreakdown.fromJson(json['deadlines'] ?? {}),
      memberWorkloads: memberList,
    );
  }
}
