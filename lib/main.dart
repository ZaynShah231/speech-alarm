import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'alarm_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AlarmPage(),
    );
  }
}

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final List<Map<String, dynamic>> _alarms = [];
  int _alarmId = 0;

  Future<void> _addAlarm() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;

    final now = DateTime.now();
    DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    final id = _alarmId++;

    await AlarmService.scheduleAlarm(id: id, time: alarmTime);

    setState(() {
      _alarms.add({"id": id, "time": alarmTime});
    });
  }

  String _format(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.hour >= 12 ? "PM" : "AM";
    return "$h:$m $p";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Speech Alarm")),
      body: ListView.builder(
        itemCount: _alarms.length,
        itemBuilder: (_, i) {
          final alarm = _alarms[i];
          return ListTile(
            leading: const Icon(Icons.alarm),
            title: Text(_format(alarm["time"])),
            trailing: IconButton(
              icon: const Icon(Icons.stop, color: Colors.red),
              onPressed: () async {
                await AlarmService.stopAlarm(alarm["id"]);
                setState(() => _alarms.removeAt(i));
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
