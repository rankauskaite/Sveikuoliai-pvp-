import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalService {
  final CollectionReference goalCollection =
      FirebaseFirestore.instance.collection('goals');

  // create
  Future<void> createGoalEntry(GoalModel goal) async {
    await goalCollection.doc(goal.id).set(goal.toJson()); 
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
    await goalCollection.doc(goal.id).update(data);
  }

  // delete
  Future<void> deleteGoalEntry(String id) async {
    await goalCollection.doc(id).delete();
  }
}
