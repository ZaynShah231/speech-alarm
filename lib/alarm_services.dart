import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

FlutterTts? _tts;
Timer? _repeatTimer;

const String _alarmRunningKey = "alarm_running";

@pragma('vm:entry-point')
Future<void> speechAlarmCallback() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_alarmRunningKey, true);

  _tts = FlutterTts();
  await _tts!.setLanguage("en-US");
  await _tts!.setSpeechRate(0.25);
  await _tts!.setPitch(1.0);

  Future<void> speak() async {
    final running = prefs.getBool(_alarmRunningKey) ?? false;
    if (!running) return;
    await _tts!.speak(
      "Wake up. Bhaiya uth jao. Kitni dafa bolna paray ga.",
    );
  }

  await speak();

  _repeatTimer = Timer.periodic(
    const Duration(seconds: 6),
        (_) async {
      final running = prefs.getBool(_alarmRunningKey) ?? false;
      if (!running) {
        _repeatTimer?.cancel();
        await _tts?.stop();
        return;
      }
      await speak();
    },
  );
}

class AlarmService {
  /// Schedule alarm
  static Future<void> scheduleAlarm({
    required int id,
    required DateTime time,
  }) async {
    await AndroidAlarmManager.oneShotAt(
      time,
      id,
      speechAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> stopAlarm(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alarmRunningKey, false);


    await AndroidAlarmManager.cancel(id);


    final FlutterTts uiTts = FlutterTts();
    await uiTts.stop();

    _repeatTimer?.cancel();
    _repeatTimer = null;
  }
}
