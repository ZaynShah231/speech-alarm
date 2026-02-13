import 'package:flutter/material.dart';
import 'alarm_services.dart';

class AlarmRingPage extends StatelessWidget {
  const AlarmRingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.now().format(context);

    return Scaffold(
      backgroundColor: Colors.red.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "ALARM RINGING",
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            const SizedBox(height: 20),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await AlarmService.stopAlarm(0);
                Navigator.of(context).pop();
              },
              child: const Text("STOP ALARM"),
            ),
          ],
        ),
      ),
    );
  }
}
