import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/goal_type_model.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';
import 'package:sveikuoliai/services/goal_task_services.dart';
import 'package:sveikuoliai/services/goal_type_services.dart';

class SharedGoalService {
  final CollectionReference sharedGoalCollection =
      FirebaseFirestore.instance.collection('shared_goals');
  final GoalTypeService _goalTypeService = GoalTypeService();

  // create
  Future<void> createSharedGoalEntry(SharedGoal sharedGoal) async {
    final docRef = sharedGoal.id.isNotEmpty
        ? sharedGoalCollection.doc(sharedGoal.id)
        : sharedGoalCollection.doc(); // Jei id tuščias, sugeneruojam naują
    await docRef.set(sharedGoal.toJson()..['id'] = docRef.id);
  }

  // read
  Future<SharedGoal?> getSharedGoalEntry(String id) async {
    DocumentSnapshot doc = await sharedGoalCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return SharedGoal.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // read all user's goals
  Future<List<SharedGoalInformation>> getSharedUserGoals(
      String username) async {
    // 1. Gaunam visas draugystes kur user1 == userId
    QuerySnapshot querySnapshot =
        await sharedGoalCollection.where('user1Id', isEqualTo: username).get();

    // 2. Ir visas kur user2 == userId
    QuerySnapshot querySnapshot2 =
        await sharedGoalCollection.where('user2Id', isEqualTo: username).get();

    List<QueryDocumentSnapshot> allDocs = [
      ...querySnapshot.docs,
      ...querySnapshot2.docs
    ];

    // Sukuriame sąrašą HabitInformation, užpildytą HabitType duomenimis
    List<SharedGoalInformation> goalsWithTypes = [];

    for (var doc in allDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final sharedGoal = SharedGoal.fromJson(doc.id, data);
      final goalTypeId = sharedGoal.goalTypeId;

      // Gaukime HabitType pagal habitTypeId
      GoalType? goalType = await _goalTypeService.getGoalTypeEntry(goalTypeId);

      // Galite pridėti patikrinimą, jei habitType yra null
      if (goalType == null) {
        // Galite užfiksuoti klaidą arba atlikti kitą veiksmą
        continue; // Tęsiame su kitais įpročiais
      }
      // Sukurkime HabitInformation su sujungtu HabitType
      var goalInfo = SharedGoalInformation.fromJson(sharedGoal, goalType);

      goalsWithTypes.add(goalInfo);
    }

    return goalsWithTypes;
  }

  // update
  Future<void> updateSharedGoalEntry(SharedGoal sharedGoal) async {
    Map<String, dynamic> data = sharedGoal.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    if (data.isNotEmpty) {
      await sharedGoalCollection.doc(sharedGoal.id).update(data);
    }
  }

  Future<void> updateGoalPoints(String id, int points) async {
    // Atnaujinimas į duomenų bazę, pavyzdžiui, Firebase
    await sharedGoalCollection.doc(id).update({
      'points': points,
    });
  }

  // delete
  Future<bool> deleteSharedGoalEntry(String id) async {
    SharedGoal? model = await getSharedGoalEntry(id);
    GoalType? type = await _goalTypeService.getGoalTypeEntry(model!.goalTypeId);
    if (type?.type == "custom") {
      await _goalTypeService.deleteGoalTypeEntry(type!.id);
    }
    final goalTaskService = GoalTaskService();
    await goalTaskService.deleteGoalTasks(id);
    DocumentSnapshot doc = await sharedGoalCollection.doc(id).get();
    if (!doc.exists) return false;
    await sharedGoalCollection.doc(id).delete();
    return true;
  }

  // Get all shared goals for a user
  Stream<List<SharedGoal>> getSharedGoalsForUser(String userId) {
    return sharedGoalCollection
        .where('user1Id', isEqualTo: userId)
        .where('user2Id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                SharedGoal.fromJson(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}
