import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/notification_model.dart';

/// motyvacines zinutes
class DefaultNotifications {
  static final List<String> motivationalMessages = [
    // Esamos
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
    "Įpročiai – tavo supergalia. Naudok ją kasdien 🦸‍♀️",
    "Kai kartoji, stiprėji. Kartok gėrį 🌼",
    "Tavo šiandienos pastangos – rytojaus rezultatai 🔁",
    "Kiekvienas mažas „taip sau“ kuria stipresnę tave 🔔",
    "Neskubėk – net lėtas progresas yra progresas 🐢",
    "Sunku? Vadinasi, tu augi 💪🌱",
    "Geriausias laikas pradėti – buvo vakar. Antras geriausias – šiandien 🕒",
    "Tavo įpročiai kalba garsiau nei tavo žodžiai 🔄",
    "Kiekvienas iššūkis – galimybė sužydėti 🌷",
    "Tavo kelionė unikali – mėgaukis kiekvienu žingsniu 🚶‍♂️✨",
    "Net jei krenti – atsikėlei, ir tai jau laimėjimas 🧡",
    "Kiekviena pastanga padeda tavo vidiniam sodui sužydėti 🌻",
    "Nepalygink savo pradžios su kitų viduriu 🚀",
    "Tu esi progreso kelyje, ir tai nuostabu 💫",
    "Dėmesingumas gimsta iš mažų sprendimų 🧘‍♀️",
    "Vienas žingsnis šiandien – mažiau abejonių rytoj ⏳",
  ];

  static String getRandomMessage() {
    motivationalMessages.shuffle();
    return motivationalMessages.first;
  }
}

class AppNotificationService {
  final CollectionReference notificationCollection =
      FirebaseFirestore.instance.collection('notifications');

  // create
  Future<void> createNotification(AppNotification notification) async {
    Map<String, dynamic> data = notification.toJson();

    data.removeWhere((key, value) => value == null); // pasalinu `null` reikšmes

    await notificationCollection.doc(notification.id).set(data);
  }

  // read
  Future<AppNotification?> getNotification(String id) async {
    DocumentSnapshot doc = await notificationCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppNotification.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // update
  Future<void> updateNotification(AppNotification notification) async {
    Map<String, dynamic> data = notification.toJson();

    data.removeWhere((key, value) => value == null); // pasalinu `null` reikšmes

    await notificationCollection.doc(notification.id).update(data);
  }

  // delete
  Future<void> deleteNotification(String id) async {
    await notificationCollection.doc(id).delete();
  }

  // get all user's notifications
  Future<List<AppNotification>> getUserNotifications(String userId) async {
    try {
      QuerySnapshot querySnapshot = await notificationCollection
          .where('userId', isEqualTo: userId)
          //.orderBy('isRead') // Pirmiausia rodyti neperskaitytus
          //.orderBy('date', descending: true) // Po to rūšiuoti pagal datą
          .get();

      return querySnapshot.docs
          .map((doc) => AppNotification.fromJson(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Klaida gaunant pranešimus: $e");
      return [];
    }
  }

  // mark single notification as read
  Future<void> markNotificationAsRead(String id) async {
    await notificationCollection.doc(id).update({'isRead': true});
  }

  // get only unread notifications
  Future<List<AppNotification>> getUnreadNotifications(String userId) async {
    QuerySnapshot querySnapshot = await notificationCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => AppNotification.fromJson(
            doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  // useriui random zinute is statiniu siunciama
  Future<void> sendMotivationalNotification(String userId) async {
    final message = DefaultNotifications.getRandomMessage();
    final now = DateTime.now();

    final notification = AppNotification(
      id: "${userId}_$now",
      userId: userId,
      text: message,
      type: "motivational",
      date: now,
    );

    await createNotification(notification);
  }
}
