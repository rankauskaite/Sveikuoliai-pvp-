import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/habit_model.dart';

class HabitService {
  final CollectionReference habitCollection =
      FirebaseFirestore.instance.collection('habits');

  // create
  Future<void> createHabitEntry(HabitModel habit) async {
    await habitCollection.doc(habit.id).set(habit.toJson()); 
  }

  // read
  Future<HabitModel?> getHabitEntry(String id) async {
    DocumentSnapshot doc = await habitCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return HabitModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // update
  Future<void> updateHabitEntry(HabitModel habit) async {
    Map<String, dynamic> data = habit.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    await habitCollection.doc(habit.id).update(data);
  }

  // delete
  Future<void> deleteHabitEntry(String id) async {
    await habitCollection.doc(id).delete();
  }
}
