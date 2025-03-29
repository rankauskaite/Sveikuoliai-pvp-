import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/goal_model.dart';
import 'package:sveikuoliai/models/goal_type_model.dart';
import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/services/goal_type_services.dart';

class GoalService {
  final CollectionReference goalCollection =
      FirebaseFirestore.instance.collection('goals');
  final GoalTypeService _goalTypeService = GoalTypeService();

  // create
  Future<void> createGoalEntry(GoalModel goal) async {
    final docRef = goal.id.isNotEmpty
        ? goalCollection.doc(goal.id)
        : goalCollection.doc(); // Jei goal.id tuščias kuriam naują
    await docRef
        .set(goal.toJson()..['id'] = docRef.id); // Išsaugom id firestore
  }

  // read
  Future<GoalModel?> getGoalEntry(String id) async {
    DocumentSnapshot doc = await goalCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return GoalModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // read all user's goals
  Future<List<GoalInformation>> getUserGoals(String username) async {
    // Gaukime vartotojo įpročius
    QuerySnapshot snapshot =
        await goalCollection.where('userId', isEqualTo: username).get();

    // Pirmiausia sukuriame sąrašą HabitModel iš visų duomenų
    List<GoalModel> goals = snapshot.docs
        .map((doc) =>
            GoalModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();

    // Sukuriame sąrašą HabitInformation, užpildytą HabitType duomenimis
    List<GoalInformation> goalsWithTypes = [];

    // Dabar pereiname per kiekvieną HabitModel
    for (var goalModel in goals) {
      final goalTypeId = goalModel.goalTypeId;

      // Gaukime HabitType pagal habitTypeId
      GoalType? goalType = await _goalTypeService.getGoalTypeEntry(goalTypeId!);

      // Galite pridėti patikrinimą, jei habitType yra null
      if (goalType == null) {
        // Galite užfiksuoti klaidą arba atlikti kitą veiksmą
        continue; // Tęsiame su kitais įpročiais
      }

      // Sukurkime HabitInformation su sujungtu HabitType
      var goalInfo = GoalInformation.fromJson(goalModel, goalType);

      goalsWithTypes.add(goalInfo);
    }

    return goalsWithTypes;
  }

  // update
  Future<void> updateGoalEntry(GoalModel goal) async {
    Map<String, dynamic> data = goal.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    if (data.isNotEmpty) {
      await goalCollection.doc(goal.id).update(data);
    }
  }

  Future<void> updateGoalPoints(String id, int points) async {
    // Atnaujinimas į duomenų bazę, pavyzdžiui, Firebase
    await goalCollection.doc(id).update({
      'points': points,
    });
  }

  // delete
  Future<bool> deleteGoalEntry(String id) async {
    GoalModel? model = await getGoalEntry(id);
    GoalType? type =
        await _goalTypeService.getGoalTypeEntry(model!.goalTypeId!);
    if (type?.type == "custom") {
      await _goalTypeService.deleteGoalTypeEntry(type!.id);
    }
    final goalTaskService = GoalTaskService();
    await goalTaskService.deleteGoalTasks(id);
    await goalCollection.doc(id).delete();
    return true;
  }
}
