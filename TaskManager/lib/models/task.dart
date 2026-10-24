import 'user.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final User? createdBy;
  final List<User> assignees;
  final User? primaryAssignee;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String priority; // low, medium, high
  final String status; // todo, in_progress, completed
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.createdBy,
    this.assignees = const [],
    this.primaryAssignee,
    this.startDate,
    this.dueDate,
    this.priority = 'medium',
    this.status = 'todo',
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Parse createdBy
    User? creator;
    if (json['createdBy'] is Map<String, dynamic>) {
      creator = User.fromJson(json['createdBy']);
    } else if (json['createdBy'] is String) {
      creator = User(id: json['createdBy'], fullName: '', email: '');
    }

    // Parse primaryAssignee
    User? primary;
    if (json['primaryAssigneeId'] is Map<String, dynamic>) {
      primary = User.fromJson(json['primaryAssigneeId']);
    } else if (json['primaryAssigneeId'] is String) {
      primary = User(id: json['primaryAssigneeId'], fullName: '', email: '');
    }

    // Parse assignees
    List<User> parsedAssignees = [];
    if (json['assigneeIds'] is List) {
      for (var item in json['assigneeIds']) {
        if (item is Map<String, dynamic>) {
          parsedAssignees.add(User.fromJson(item));
        } else if (item is String) {
          parsedAssignees.add(User(id: item, fullName: '', email: ''));
        }
      }
    }

    return Task(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdBy: creator,
      assignees: parsedAssignees,
      primaryAssignee: primary,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdBy': createdBy?.toJson(),
      'assigneeIds': assignees.map((u) => u.toJson()).toList(),
      'primaryAssigneeId': primaryAssignee?.toJson(),
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    User? createdBy,
    List<User>? assignees,
    User? primaryAssignee,
    DateTime? startDate,
    DateTime? dueDate,
    String? priority,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      assignees: assignees ?? this.assignees,
      primaryAssignee: primaryAssignee ?? this.primaryAssignee,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
