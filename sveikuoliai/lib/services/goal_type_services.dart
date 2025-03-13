import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_type_model.dart';

class GoalTypeService {
  final CollectionReference goalTypeCollection =
      FirebaseFirestore.instance.collection('goalTypes');

  // does exist
  Future<bool> doesGoalTypeExist(String id) async {
    DocumentSnapshot doc = await goalTypeCollection.doc(id).get();
    return doc.exists;
  }

  // create
  Future<void> createGoalTypeEntry(GoalType goalType) async {
    await goalTypeCollection.doc(goalType.id).set(goalType.toJson());
  }

  // defaultiniai
  Future<void> fillDefaultGoalTypes() async {
    for (var goalType in GoalType.defaultGoalTypes) {
      bool exists = await doesGoalTypeExist(goalType.id);
      if (!exists) {
        try {
          await createGoalTypeEntry(goalType);
          print("pridėtas tikslas: ${goalType.title}");
        } catch (e) {
          print("klaida įrašant '${goalType.title}' į Firestore: $e");
        }
      } else {
        print("Tikslas '${goalType.title}' jau yra Firestore.");
      }
    }
    print("Visi siūlomi tikslai patikrinti ir įkelti!");
  }

  // read all
  Future<List<GoalType>> getAllGoalTypes() async {
    QuerySnapshot snapshot = await goalTypeCollection.get();
    return snapshot.docs.map((doc) {
      return GoalType.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // read
  Future<GoalType?> getGoalTypeEntry(String id) async {
    DocumentSnapshot doc = await goalTypeCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return GoalType.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // update
  Future<void> updateGoalTypeEntry(GoalType goalType) async {
    Map<String, dynamic> data = goalType.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    await goalTypeCollection.doc(goalType.id).update(data);
    print(" Atnaujintas tikslas: ${goalType.title}");
  }

  // delete
  Future<void> deleteGoalTypeEntry(String id) async {
    await goalTypeCollection.doc(id).delete();
    print(" Tikslas ištrintas: $id");
  }
}
