class SessionModel {
  final String id;
  final String subjectId;
  final String subjectName;
  final String chapter;
  final String revisionStage;
  final String? notes;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;

  const SessionModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.chapter,
    required this.revisionStage,
    this.notes,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
  });

  bool get isCompleted => endTime != null;

  Duration get duration => Duration(seconds: durationSeconds);

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] as String,
      subjectId: map['subject_id'] as String,
      subjectName: map['subject_name'] as String,
      chapter: map['chapter'] as String,
      revisionStage: map['revision_stage'] as String,
      notes: map['notes'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: map['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int)
          : null,
      durationSeconds: map['duration_seconds'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'chapter': chapter,
      'revision_stage': revisionStage,
      'notes': notes,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'duration_seconds': durationSeconds,
    };
  }

  SessionModel copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? chapter,
    String? revisionStage,
    String? notes,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
  }) {
    return SessionModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      chapter: chapter ?? this.chapter,
      revisionStage: revisionStage ?? this.revisionStage,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}
