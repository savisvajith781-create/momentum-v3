enum CheckpointStatus { green, yellow, red }

class CheckpointModel {
  final String id;
  final String title;
  final String? subjectId;
  final String? subjectName;
  final DateTime targetDate;
  final int progressPercent;
  final CheckpointStatus status;
  final String? notes;
  final DateTime createdAt;

  const CheckpointModel({
    required this.id,
    required this.title,
    this.subjectId,
    this.subjectName,
    required this.targetDate,
    required this.progressPercent,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  bool get isOverdue => daysRemaining < 0;
  bool get isDueToday => daysRemaining == 0;

  factory CheckpointModel.fromMap(Map<String, dynamic> map) {
    return CheckpointModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subjectId: map['subject_id'] as String?,
      subjectName: map['subject_name'] as String?,
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int),
      progressPercent: map['progress_percent'] as int,
      status: CheckpointStatus.values[map['status'] as int],
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'target_date': targetDate.millisecondsSinceEpoch,
      'progress_percent': progressPercent,
      'status': status.index,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  CheckpointModel copyWith({
    String? id,
    String? title,
    String? subjectId,
    String? subjectName,
    DateTime? targetDate,
    int? progressPercent,
    CheckpointStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return CheckpointModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      targetDate: targetDate ?? this.targetDate,
      progressPercent: progressPercent ?? this.progressPercent,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
