import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/notification_model.dart';

class AppNotificationService {
  final CollectionReference notificationCollection =
      FirebaseFirestore.instance.collection('notifications');

  // create
  Future<void> createNotification(AppNotification notification) async {
    DocumentReference docRef =
        await notificationCollection.add(notification.toJson());
    await docRef.update({'id': docRef.id});
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
    data.removeWhere(
        (key, value) => value == null); // 🔹 Pašalinam `null` reikšmes
    await notificationCollection.doc(notification.id).update(data);
  }

  // delete
  Future<void> deleteNotification(String id) async {
    await notificationCollection.doc(id).delete();
  }

  // Paimame visus vartotojo pranešimus ir rodome neperskaitytus viršuje
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

  //
  Future<void> markNotificationAsRead(String id) async {
    await notificationCollection.doc(id).update({'isRead': true});
  }

  // read unread
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
}
