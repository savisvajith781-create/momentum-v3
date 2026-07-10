import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';
import 'core_providers.dart';

class SettingsState {
  final int dailyTargetSeconds;
  final int accentColorValue;
  final int quoteFrequencyMinutes;

  const SettingsState({
    required this.dailyTargetSeconds,
    required this.accentColorValue,
    required this.quoteFrequencyMinutes,
  });

  Color get accentColor => Color(accentColorValue);

  double get dailyTargetHours => dailyTargetSeconds / 3600.0;

  SettingsState copyWith({
    int? dailyTargetSeconds,
    int? accentColorValue,
    int? quoteFrequencyMinutes,
  }) {
    return SettingsState(
      dailyTargetSeconds: dailyTargetSeconds ?? this.dailyTargetSeconds,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      quoteFrequencyMinutes:
          quoteFrequencyMinutes ?? this.quoteFrequencyMinutes,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsService _service;

  SettingsNotifier(this._service)
      : super(SettingsState(
          dailyTargetSeconds: _service.dailyTargetSeconds,
          accentColorValue: _service.accentColor,
          quoteFrequencyMinutes: _service.quoteFrequencyMinutes,
        ));

  Future<void> setDailyTarget(int seconds) async {
    await _service.setDailyTargetSeconds(seconds);
    state = state.copyWith(dailyTargetSeconds: seconds);
  }

  Future<void> setAccentColor(int colorValue) async {
    await _service.setAccentColor(colorValue);
    state = state.copyWith(accentColorValue: colorValue);
  }

  Future<void> setQuoteFrequency(int minutes) async {
    await _service.setQuoteFrequencyMinutes(minutes);
    state = state.copyWith(quoteFrequencyMinutes: minutes);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.read(settingsServiceProvider));
});
