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
    return SharedGoal.fromJson(doc.data() as Map<String, dynamic>);
  }

  // read all user's goals
  Future<List<SharedGoalInformation>> getSharedUserGoals(
      String username) async {
    try {
      // 1. Gaunam visas draugystes kur user1 == userId
      QuerySnapshot querySnapshot = await sharedGoalCollection
          .where('user1Id', isEqualTo: username)
          .get();
      print(
          'SharedGoal snapshot (user1): ${querySnapshot.docs.length} for user: $username');

      // 2. Ir visas kur user2 == userId
      QuerySnapshot querySnapshot2 = await sharedGoalCollection
          .where('user2Id', isEqualTo: username)
          .get();
      print(
          'SharedGoal snapshot (user2): ${querySnapshot2.docs.length} for user: $username');

      List<QueryDocumentSnapshot> allDocs = [
        ...querySnapshot.docs,
        ...querySnapshot2.docs
      ];

      // Sukuriame sąrašą SharedGoalInformation, užpildytą GoalType duomenimis
      List<SharedGoalInformation> goalsWithTypes = [];

      for (var doc in allDocs) {
        final data = doc.data();
        if (data == null) {
          print(
              'Warning: SharedGoal document ${doc.id} has no data, skipping...');
          continue;
        }

        // Konvertuojame Map<dynamic, dynamic> į Map<String, dynamic>
        final Map<String, dynamic> convertedData = data is Map
            ? data.map((key, value) => MapEntry(key.toString(), value))
            : {};
        print('SharedGoal document ${doc.id} data: $convertedData');

        try {
          final sharedGoal = SharedGoal.fromJson(convertedData);
          final goalTypeId = sharedGoal.goalTypeId;

          // Gaukime GoalType pagal goalTypeId
          GoalType? goalType =
              await _goalTypeService.getGoalTypeEntry(goalTypeId);
          if (goalType == null) {
            print(
                'Warning: No GoalType found for goalTypeId: $goalTypeId, skipping shared goal ${sharedGoal.id}');
            continue;
          }

          // Sukurkime SharedGoalInformation su sujungtu GoalType
          var goalInfo = SharedGoalInformation.fromJson({
            'id': sharedGoal.id,
            'sharedGoalModel': sharedGoal.toJson(),
            'goalType': goalType.toJson(),
          });

          goalsWithTypes.add(goalInfo);
        } catch (e) {
          print(
              'Failed to parse SharedGoalInformation for document ${doc.id}: $e');
          continue;
        }
      }

      print('Shared goals with types loaded: ${goalsWithTypes.length}');
      return goalsWithTypes;
    } catch (e) {
      print('Klaida gaunant bendrus tikslus: $e');
      return []; // Grąžiname tuščią sąrašą, jei įvyksta klaida
    }
  }

  Future<List<SharedGoal>> getSharedGoalsForUsers(
      String username, String friendUsername) async {
    // Query for goals where both user1Id and user2Id match the given usernames
    QuerySnapshot querySnapshot = await sharedGoalCollection
        .where('user1Id', isEqualTo: username)
        .where('user2Id', isEqualTo: friendUsername)
        .get();

    QuerySnapshot querySnapshotReverse = await sharedGoalCollection
        .where('user1Id', isEqualTo: friendUsername)
        .where('user2Id', isEqualTo: username)
        .get();

    // Combine the results
    List<QueryDocumentSnapshot> allDocs = [
      ...querySnapshot.docs,
      ...querySnapshotReverse.docs
    ];

    // Map the documents to SharedGoal objects
    return allDocs
        .map((doc) =>
            SharedGoal.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
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
                SharedGoal.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // jeigu getSharedGoalsForUser() negrazina nieko, bandyti naudoti sita koda:
//   Stream<List<SharedGoal>> getSharedGoalsForUser(String userId) async* {
//   final query1 = sharedGoalCollection.where('user1Id', isEqualTo: userId).snapshots();
//   final query2 = sharedGoalCollection.where('user2Id', isEqualTo: userId).snapshots();

//   await for (final user1Snap in query1) {
//     final user2Snap = await query2.first; // arba gali jungti kitaip

//     final allDocs = {
//       ...user1Snap.docs,
//       ...user2Snap.docs,
//     };

//     yield allDocs
//         .map((doc) => SharedGoal.fromJson(doc.id, doc.data() as Map<String, dynamic>))
//         .toList();
//   }
// }
}
