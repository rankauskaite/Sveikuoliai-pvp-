import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalService {
  final CollectionReference goalCollection =
      FirebaseFirestore.instance.collection('goals');

  // create
  Future<void> createGoalEntry(GoalModel goal) async {
    final docRef = goal.id.isNotEmpty
        ? goalCollection.doc(goal.id)
        : goalCollection.doc(); // Jei goal.id tuščias kuriam naują
    await docRef.set(goal.toJson()..['id'] = docRef.id); // Išsaugom id firestore
  }

  // read
  Future<GoalModel?> getGoalEntry(String id) async {
    DocumentSnapshot doc = await goalCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return GoalModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // update
  Future<void> updateGoalEntry(GoalModel goal) async {
    Map<String, dynamic> data = goal.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    if (data.isNotEmpty) {
      await goalCollection.doc(goal.id).update(data);
    }
  }

  // delete
  Future<bool> deleteGoalEntry(String id) async {
    DocumentSnapshot doc = await goalCollection.doc(id).get();
    if (!doc.exists) return false;
    await goalCollection.doc(id).delete();
    return true;
  }
}
