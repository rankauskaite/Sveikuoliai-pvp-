import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/shared_goal_model.dart';

class SharedGoalService {
  final CollectionReference sharedGoalCollection =
      FirebaseFirestore.instance.collection('shared_goals');

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

  // update
  Future<void> updateSharedGoalEntry(SharedGoal sharedGoal) async {
    Map<String, dynamic> data = sharedGoal.toJson();
    data.removeWhere((key, value) => value == null); // Pašalinam null laukus
    if (data.isNotEmpty) {
      await sharedGoalCollection.doc(sharedGoal.id).update(data);
    }
  }

  // delete
  Future<bool> deleteSharedGoalEntry(String id) async {
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
        .map((snapshot) =>
            snapshot.docs.map((doc) => SharedGoal.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }
}
