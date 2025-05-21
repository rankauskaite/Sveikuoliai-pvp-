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

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();

    await _requestExactAlarmsPermission();
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

      // Įrašom, kad jau prašėm leidimo
      await prefs.setBool('exact_alarm_permission_requested', true);
    }
    // Android 13+ reikia leidimo atskirai
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
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
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
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
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> sendFriendshipRequestNotification(
      String userId, String friendName, String friendUsername) async {
    await _notificationsPlugin.zonedSchedule(
      999,
      'Draugystės pasiūlymas',
      '$friendName (@$friendUsername) nori tapti tavo draugu!',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'friendship_channel',
          'Draugystės priminimai',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> scheduleTwoMotivationsPerDay() async {
    final messages = [
      'Tu gali viską!',
      'Kiekviena diena – nauja pradžia!',
      'Niekas tavęs nesustabdys!',
      'Net mažas žingsnis pirmyn yra progresas!',
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
