import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_task_model.dart';

class GoalTaskService {
  final CollectionReference goalTaskCollection =
      FirebaseFirestore.instance.collection('goalTasks');

  // create
  Future<void> createGoalTaskEntry(GoalTask goalTask) async {
    await goalTaskCollection.doc(goalTask.id).set(goalTask.toJson());
  }

  // read
  Future<GoalTask?> getGoalTaskEntry(String id) async {
    DocumentSnapshot doc = await goalTaskCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return GoalTask.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // update
  Future<void> updateGoalTaskEntry(GoalTask goalTask) async {
    Map<String, dynamic> data = goalTask.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    await goalTaskCollection.doc(goalTask.id).update(data);
  }

  // delete
  Future<void> deleteGoalTaskEntry(String id) async {
    await goalTaskCollection.doc(id).delete();
  }
}
