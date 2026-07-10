class AppConstants {
  // App info
  static const String appName = 'Momentum';
  static const String appTagline = 'Minimal Study Tracker';
  static const String appVersion = '1.0.0';

  // Window
  static const double minWindowWidth = 1100;
  static const double minWindowHeight = 720;
  static const double defaultWindowWidth = 1280;
  static const double defaultWindowHeight = 800;

  // Navigation Rail
  static const double navRailWidth = 72;
  static const double navRailExpandedWidth = 200;

  // Default daily target (seconds)
  static const int defaultDailyTargetSeconds = 9 * 3600; // 9 hours

  // Quote rotation interval
  static const int quoteRotationMinutes = 60;

  // Default subjects
  static const List<String> defaultSubjects = [
    'AFM',
    'FR',
    'Audit',
    'Gym',
    'Break',
  ];

  // Default study session stages (fully user-editable from Settings)
  static const List<String> defaultStudyStages = [
    'First Pass',
    'Review',
    'Practice',
    'Mock Test',
    'Other',
  ];

  // Deprecated alias kept for backwards compatibility; use defaultStudyStages.
  static const List<String> revisionStages = defaultStudyStages;

  // Subject colors (hex)
  static const Map<String, int> subjectColors = {
    'AFM': 0xFF4F8CFF,
    'FR': 0xFF42D392,
    'Audit': 0xFFFFB84D,
    'Gym': 0xFFFF6B6B,
    'Break': 0xFF9B8FFF,
    'Custom': 0xFFA6B0C3,
  };

  // Subject icons
  static const Map<String, String> subjectIcons = {
    'AFM': '📊',
    'FR': '📖',
    'Audit': '🔍',
    'Gym': '💪',
    'Break': '☕',
    'Custom': '⭐',
  };

  // DB table names
  static const String tableSubjects = 'subjects';
  static const String tableSessions = 'sessions';
  static const String tableTasks = 'tasks';
  static const String tableDailyTargets = 'daily_targets';
  static const String tableCheckpoints = 'checkpoints';
  static const String tableSettings = 'settings';

  // Hive box names
  static const String hiveSettingsBox = 'settings';
  static const String hiveQuoteBox = 'quotes';

  // Settings keys
  static const String keyDailyTarget = 'daily_target_seconds';
  static const String keyAccentColor = 'accent_color';
  static const String keyQuoteFrequency = 'quote_frequency_minutes';
  static const String keyWindowWidth = 'window_width';
  static const String keyWindowHeight = 'window_height';
  static const String keyWindowX = 'window_x';
  static const String keyWindowY = 'window_y';
  static const String keyStudyStages = 'study_stages';
}
