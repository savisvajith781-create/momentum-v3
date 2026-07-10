import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SettingsService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int get dailyTargetSeconds =>
      _prefs.getInt(AppConstants.keyDailyTarget) ??
      AppConstants.defaultDailyTargetSeconds;

  Future<void> setDailyTargetSeconds(int seconds) async {
    await _prefs.setInt(AppConstants.keyDailyTarget, seconds);
  }

  int get accentColor =>
      _prefs.getInt(AppConstants.keyAccentColor) ?? 0xFF4F8CFF;

  Future<void> setAccentColor(int colorValue) async {
    await _prefs.setInt(AppConstants.keyAccentColor, colorValue);
  }

  int get quoteFrequencyMinutes =>
      _prefs.getInt(AppConstants.keyQuoteFrequency) ??
      AppConstants.quoteRotationMinutes;

  Future<void> setQuoteFrequencyMinutes(int minutes) async {
    await _prefs.setInt(AppConstants.keyQuoteFrequency, minutes);
  }

  double get savedWindowWidth =>
      _prefs.getDouble(AppConstants.keyWindowWidth) ??
      AppConstants.defaultWindowWidth;

  Future<void> setWindowWidth(double width) async {
    await _prefs.setDouble(AppConstants.keyWindowWidth, width);
  }

  double get savedWindowHeight =>
      _prefs.getDouble(AppConstants.keyWindowHeight) ??
      AppConstants.defaultWindowHeight;

  Future<void> setWindowHeight(double height) async {
    await _prefs.setDouble(AppConstants.keyWindowHeight, height);
  }

  double? get savedWindowX => _prefs.getDouble(AppConstants.keyWindowX);
  double? get savedWindowY => _prefs.getDouble(AppConstants.keyWindowY);

  Future<void> setWindowPosition(double x, double y) async {
    await _prefs.setDouble(AppConstants.keyWindowX, x);
    await _prefs.setDouble(AppConstants.keyWindowY, y);
  }

  List<String> get studyStages {
    final saved = _prefs.getStringList(AppConstants.keyStudyStages);
    if (saved == null || saved.isEmpty) {
      return List<String>.from(AppConstants.defaultStudyStages);
    }
    return saved;
  }

  Future<void> setStudyStages(List<String> stages) async {
    await _prefs.setStringList(AppConstants.keyStudyStages, stages);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
