import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/user_model.dart';
// import '../models/habit_model.dart';
// import '../models/goal_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //  add user
  Future<void> addUser(UserModel user) async {
    await _db.collection('users').doc(user.username).set(user.toJson());
    // .doc - priskiria automatini id
  }

  //  get users
  Future<List<UserModel>> getUsers() async {
    QuerySnapshot snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  // select one user
  Future<UserModel?> getUserById(String userId) async {
    DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // add habit
//   Future<void> addHabit(HabitModel habit) async {
//     await _db.collection('habits').doc(habit.id).set(habit.toJson());
//   }

  // add goal
//   Future<void> addGoal(GoalModel goal) async {
//     await _db.collection('goals').doc(goal.id).set(goal.toJson());
//   }
}
