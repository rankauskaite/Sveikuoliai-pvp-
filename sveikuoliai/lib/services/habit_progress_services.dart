import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/habit_model.dart';
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
    return HabitProgress.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<Map<String, List<HabitProgress>>> getAllHabitProgress(
      List<HabitInformation> habits) async {
    try {
      // Gauname habits iš sesijos
      if (habits.isEmpty) {
        return {};
      }

      // Ištraukiame visus habitId
      List<String> habitIds =
          habits.map((habit) => habit.habitModel.id).toList();

      if (habitIds.isEmpty) {
        return {};
      }

      // Firestore užklausa pagal habitId sąrašą
      QuerySnapshot querySnapshot = await habitProgressCollection
          .where('habitId', whereIn: habitIds)
          .get();

      Map<String, List<HabitProgress>> progressByHabit = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data == null) {
          continue;
        }

        final Map<String, dynamic> convertedData = data is Map
            ? data.map((key, value) => MapEntry(key.toString(), value))
            : {};
        convertedData['id'] = doc.id;

        try {
          final habitProgress = HabitProgress.fromJson(convertedData);
          progressByHabit
              .putIfAbsent(habitProgress.habitId, () => [])
              .add(habitProgress);
        } catch (e) {
          print('Failed to parse HabitProgress for document ${doc.id}: $e');
          continue;
        }
      }

      print('HabitProgress loaded: ${progressByHabit.length} habits');
      print('HabitProgress map: $progressByHabit');
      return progressByHabit;
    } catch (e) {
      print('Klaida gaunant įpročių progresą: $e');
      return {};
    }
  }

  // read last progress
  Future<HabitProgress?> getLatestHabitProgress(String habitId) async {
    QuerySnapshot querySnapshot = await habitProgressCollection
        .where('habitId', isEqualTo: habitId)
        .get();

    if (querySnapshot.docs.isEmpty)
      return null; // Jei nėra įrašų, grąžiname null

    var doc = querySnapshot.docs.last;
    return HabitProgress.fromJson(doc.data() as Map<String, dynamic>);
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
          HabitProgress.fromJson(doc.data() as Map<String, dynamic>);
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
