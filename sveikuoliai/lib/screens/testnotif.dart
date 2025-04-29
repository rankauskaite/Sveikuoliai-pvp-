import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_helper.dart';

class TestNotificationsScreen extends StatelessWidget {
  const TestNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikacijų testas')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final now = DateTime.now();
            await NotificationHelper.scheduleDailyNotification(
              id: 999,
              title: 'Testas 🧪',
              body: 'Notifikacija veikia! Laikas: ${now.hour}:${now.minute + 1}',
              hour: now.hour,
              minute: now.minute + 1,
            );
            print("✅ Notifikacija suplanuota po 1 minutės");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifikacija suplanuota!')),
            );
          },
          child: const Text('Testuoti notifikaciją'),
        ),
      ),
    );
  }
}
