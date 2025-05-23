import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzData.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Vilnius'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);

    // Handle notification permissions
    await _handleNotificationPermission();

    // Request exact alarms permission (unchanged)
    await _requestExactAlarmsPermission();
  }

  static Future<void> _handleNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionAsked =
        prefs.getBool('notification_permission_asked') ?? false;
    final notificationsEnabled = prefs.getBool('notifications') ?? true;

    if (permissionAsked || !notificationsEnabled) {
      return; // Skip if permission was already asked or notifications are disabled
    }

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    bool? granted;
    if (Platform.isAndroid) {
      granted = await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await prefs.setBool('notification_permission_asked', true);

    if (granted == true) {
      await prefs.setBool('notifications', true);
    } else {
      await prefs.setBool('notifications', false);
    }
  }

  static Future<void> _requestExactAlarmsPermission() async {
    if (!Platform.isAndroid) return;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt < 33) return;

    final prefs = await SharedPreferences.getInstance();
    final alreadyRequested =
        prefs.getBool('exact_alarm_permission_requested') ?? false;

    if (!alreadyRequested) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      await prefs.setBool('exact_alarm_permission_requested', true);
    }
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation_channel',
          'Motyvaciniai priminimai',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> testNotificationNow() async {
    final scheduled =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    await _notificationsPlugin.zonedSchedule(
      999,
      'Testas',
      'Ar matai šį pranešimą?',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation_channel',
          'Motyvaciniai priminimai',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> scheduleTwoMotivationsPerDay() async {
    final messages = [
      'Tu gali viską! 🎈',
      'Kiekviena diena – nauja pradžia! 🌅',
      'Niekas tavęs nesustabdys! 🥇',
      'Net mažas žingsnis pirmyn yra progresas! 🚶‍♀️',
      "Puikus darbas! Kiekviena diena priartina tave prie tikslo 🌱",
      "Net mažas žingsnis yra progresas 🚶‍♀️",
      "Dideli pokyčiai prasideda nuo mažų įpročių ✨",
      "Nepamiršk: augalas auga tik jei jį laistai – kaip ir tavo įpročiai 🌿",
      "Kiekvienas užpildytas įprotis yra pergalė 🏆",
      "Maži žingsneliai – dideli tikslai! 🎯",
      "Tau puikiai sekasi! Nesustok dabar 🌈",
      "Tavo pastangos matomos – nesustok! 🌟",
      "Mažais žingsniais į didelius tikslus 💫",
      "Jei vakar nepavyko – šiandien nauja diena! ☀️",
      "Progresas svarbiau už tobulumą 🌱",
      "Dideli dalykai prasideda nuo mažų sprendimų 💚",
      "Tu gali daugiau nei galvoji. Pasitikėk savimi! 🔒✨",
      "Prisimink, dėl ko pradėjai. Tai verta! 💪",
      "Šiandien – puiki diena padaryti kažką dėl savęs 💖",
      "Kiekviena diena – nauja galimybė žydėti 🌸",
      "Tu verta visko, apie ką svajoji – tik nepamiršk žingsniuoti 💞",
    ]..shuffle();

    String getRandomMessage() {
      messages.shuffle();
      return messages.first;
    }

    await scheduleDailyNotification(
      id: 1,
      title: "Rytinė motyvacija",
      body: getRandomMessage(),
      hour: 9,
      minute: 0,
    );

    await scheduleDailyNotification(
      id: 2,
      title: "Vakarinė motyvacija",
      body: getRandomMessage(),
      hour: 21,
      minute: 0,
    );
  }
}
