import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sveikuoliai/models/habit_progress_model.dart';

class HabitProgressService {
  final CollectionReference habitProgressCollection =
      FirebaseFirestore.instance.collection('habit_progress');

  // create
  Future<void> createHabitProgressEntry(HabitProgress habitProgress) async {
    await habitProgressCollection
        .doc(habitProgress.id)
        .set(habitProgress.toJson());
  }

  // read
  Future<HabitProgress?> getHabitProgressEntry(String id) async {
    DocumentSnapshot doc = await habitProgressCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return HabitProgress.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // read all habit's progress
  Future<List<HabitProgress>> getAllHabitProgress(String habitId) async {
    QuerySnapshot querySnapshot = await habitProgressCollection
        .where('habitId', isEqualTo: habitId)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            HabitProgress.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  // read last progress
  Future<HabitProgress?> getLatestHabitProgress(String habitId) async {
    QuerySnapshot querySnapshot = await habitProgressCollection
        .where('habitId', isEqualTo: habitId)
        .get();

    if (querySnapshot.docs.isEmpty)
      return null; // Jei nėra įrašų, grąžiname null

    var doc = querySnapshot.docs.last;
    return HabitProgress.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<HabitProgress?> getTodayHabitProgress(String habitId) async {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime tomorrowStart = todayStart.add(Duration(days: 1));

    QuerySnapshot querySnapshot = await habitProgressCollection
        .where('habitId', isEqualTo: habitId)
        .get(); // Paimam visus šio įpročio įrašus

    for (var doc in querySnapshot.docs) {
      HabitProgress progress =
          HabitProgress.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      if (progress.date.isAfter(todayStart) &&
          progress.date.isBefore(tomorrowStart)) {
        return progress; // Grąžinam šiandienos įrašą
      }
    }

    return null; // Jei nerado šiandienos įrašo
  }

  // update
  Future<void> updateHabitProgressEntry(HabitProgress habitProgress) async {
    Map<String, dynamic> data = habitProgress.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    await habitProgressCollection.doc(habitProgress.id).update(data);
  }

  // delete
  Future<void> deleteHabitProgressEntry(String id) async {
    await habitProgressCollection.doc(id).delete();
  }

  Future<void> deleteHabitProgresses(String habitId) async {
    // Atlikti užklausą, kad gautum visus įrašus su tokiu habitId
    var snapshot = await habitProgressCollection
        .where('habitId', isEqualTo: habitId) // Filtruoti pagal habitId
        .get();

    // Ištrinti visus atitinkančius įrašus
    for (var doc in snapshot.docs) {
      await doc.reference.delete(); // Ištrina kiekvieną dokumentą
    }
  }
}
