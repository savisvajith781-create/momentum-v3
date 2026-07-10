import 'subject_model.dart';

enum TimerStatus { idle, running, paused }

class TimerState {
  final TimerStatus status;
  final SubjectModel? subject;
  final String chapter;
  final String revisionStage;
  final String? notes;
  final DateTime? startTime;
  final DateTime? pauseTime;
  final int elapsedSeconds;
  final String? sessionId;

  const TimerState({
    this.status = TimerStatus.idle,
    this.subject,
    this.chapter = '',
    this.revisionStage = 'R1',
    this.notes,
    this.startTime,
    this.pauseTime,
    this.elapsedSeconds = 0,
    this.sessionId,
  });

  bool get isIdle => status == TimerStatus.idle;
  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isActive => status != TimerStatus.idle;

  String get formattedTime {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  TimerState copyWith({
    TimerStatus? status,
    SubjectModel? subject,
    String? chapter,
    String? revisionStage,
    String? notes,
    DateTime? startTime,
    DateTime? pauseTime,
    int? elapsedSeconds,
    String? sessionId,
    bool clearSubject = false,
    bool clearPauseTime = false,
    bool clearSessionId = false,
    bool clearNotes = false,
  }) {
    return TimerState(
      status: status ?? this.status,
      subject: clearSubject ? null : (subject ?? this.subject),
      chapter: chapter ?? this.chapter,
      revisionStage: revisionStage ?? this.revisionStage,
      notes: clearNotes ? null : (notes ?? this.notes),
      startTime: startTime ?? this.startTime,
      pauseTime: clearPauseTime ? null : (pauseTime ?? this.pauseTime),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
    );
  }
}
