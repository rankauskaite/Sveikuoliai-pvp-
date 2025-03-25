import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/habit_progress_model.dart';

class HabitProgressService {
  final CollectionReference habitProgressCollection =
      FirebaseFirestore.instance.collection('habitProgresses');

  // create
  Future<void> createHabitProgressEntry(HabitProgress habitProgress) async {
    await habitProgressCollection
        .doc(habitProgress.id)
        .set(habitProgress.toJson());

    // read
    Future<HabitProgress?> getHabitProgressEntry(String id) async {
      DocumentSnapshot doc = await habitProgressCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return HabitProgress.fromJson(doc.id, doc.data() as Map<String, dynamic>);
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
  }
}
