import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit_type_model.dart';

class HabitTypeService {
  final CollectionReference habitTypeCollection =
      FirebaseFirestore.instance.collection('habitTypes');

  // does exist
  Future<bool> doesHabitTypeExist(String id) async {
    DocumentSnapshot doc = await habitTypeCollection.doc(id).get();
    return doc.exists;
  }

  // create
  Future<void> createHabitTypeEntry(HabitType habitType) async {
    await habitTypeCollection.doc(habitType.id).set(habitType.toJson());
  }

  // sukelia default
  Future<void> fillDefaultHabitTypes() async {
    for (var habitType in HabitType.defaultHabitTypes) {
      bool exists = await doesHabitTypeExist(habitType.id);
      if (!exists) {
        try {
          await createHabitTypeEntry(habitType);
          print("Pridėtas įprotis: ${habitType.title}");
        } catch (e) {
          print("klaida įrašant '${habitType.title}' į Firestore: $e");
        }
      } else {
        print("Įprotis '${habitType.title}' jau yra Firestore.");
      }
    }
    print(" Visi siūlomi įpročiai patikrinti ir įkelti :)");
  }

  // read all
  Future<List<HabitType>> getAllHabitTypes() async {
    QuerySnapshot snapshot = await habitTypeCollection.get();
    return snapshot.docs.map((doc) {
      return HabitType.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // read
  Future<HabitType?> getHabitTypeById(String id) async {
    DocumentSnapshot doc = await habitTypeCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return HabitType.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // update
  Future<void> updateHabitTypeEntry(HabitType habitType) async {
    Map<String, dynamic> data = habitType.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    await habitTypeCollection.doc(habitType.id).update(data);
    print("Atnaujintas įprotis: ${habitType.title}");
  }

  // delete
  Future<void> deleteHabitTypeEntry(String id) async {
    await habitTypeCollection.doc(id).delete();
    print("Įprotis ištrintas: $id");
  }
}
