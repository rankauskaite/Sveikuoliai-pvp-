import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/data/default_tasks.dart';
import 'package:sveikuoliai/models/goal_task_model.dart';

class GoalTaskService {
  final CollectionReference goalTaskCollection =
      FirebaseFirestore.instance.collection('goal_tasks');

  // create
  Future<void> createGoalTaskEntry(GoalTask goalTask) async {
    await goalTaskCollection.doc(goalTask.id).set(goalTask.toJson());
  }

  // create default tasks for goal
  Future<void> createDefaultTasksForGoal({
    required String goalId,
    required String goalType,
    required String username,
    String? isFriend,
  }) async {
    List<GoalTask> defaultTasks = generateDefaultTasksForGoal(
      goalId: goalId,
      goalType: goalType,
      username: username,
      isFriend: isFriend,
    );

    for (var task in defaultTasks) {
      await createGoalTaskEntry(task);
    }
  }

  // read
  Future<GoalTask?> getGoalTaskEntry(String id) async {
    DocumentSnapshot doc = await goalTaskCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return GoalTask.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // read all goal's tasks
  Future<List<GoalTask>> getGoalTasks(String goalId) async {
    QuerySnapshot snapshot =
        await goalTaskCollection.where('goalId', isEqualTo: goalId).get();

    return snapshot.docs
        .map((doc) =>
            GoalTask.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  // update
  Future<void> updateGoalTaskEntry(GoalTask goalTask) async {
    Map<String, dynamic> data = goalTask.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    await goalTaskCollection.doc(goalTask.id).update(data);
  }

  Future<void> updateGoalTaskState(
      String id, bool isCompleted, int points) async {
    // Atnaujinimas į duomenų bazę, pavyzdžiui, Firebase
    await goalTaskCollection.doc(id).update({
      'isCompleted': isCompleted,
      'points': points,
    });
  }

  // delete
  Future<void> deleteGoalTaskEntry(String id) async {
    await goalTaskCollection.doc(id).delete();
  }

  Future<void> deleteGoalTasks(String goalId) async {
    // Atlikti užklausą, kad gautum visus įrašus su tokiu habitId
    var snapshot = await goalTaskCollection
        .where('goalId', isEqualTo: goalId) // Filtruoti pagal habitId
        .get();

    // Ištrinti visus atitinkančius įrašus
    for (var doc in snapshot.docs) {
      await doc.reference.delete(); // Ištrina kiekvieną dokumentą
    }
  }
}
