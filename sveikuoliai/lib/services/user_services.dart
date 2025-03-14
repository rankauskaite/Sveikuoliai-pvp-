import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // create
  Future<bool> createUserEntry(UserModel user) async {
    try {
      DocumentSnapshot doc = await userCollection.doc(user.username).get();
      if (doc.exists) return false; // Jei username jau užimtas, false

      await userCollection.doc(user.username).set(user.toJson());
      return true;
    } catch (e) {
      print("Klaida kuriant vartotoją: $e");
      return false;
    }
  }

  /// read
  Future<UserModel?> getUserEntry(String username) async {
    try {
      DocumentSnapshot doc = await userCollection.doc(username).get();
      if (!doc.exists || doc.data() == null) return null;

      return UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Klaida gaunant vartotojo duomenis: $e");
      return null;
    }
  }

  Future<UserModel?> getUserEntryByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await userCollection
          .where('email', isEqualTo: email)
          .limit(1) // Gaunam tik vieną vartotoją
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      var doc = querySnapshot.docs.first;
      return UserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Klaida gaunant vartotojo duomenis pagal el. paštą: $e");
      return null;
    }
  }

  // update
  Future<bool> updateUserEntry(UserModel user) async {
    try {
      Map<String, dynamic> data = user.toJson();
      data.removeWhere((key, value) => value == null); // Pašalinam null laukus

      await userCollection.doc(user.username).update(data);
      return true;
    } catch (e) {
      print("Klaida atnaujinant vartotoją: $e");
      return false;
    }
  }

  // delete
  Future<bool> deleteUserEntry(String username) async {
    try {
      await userCollection.doc(username).delete();
      return true;
    } catch (e) {
      print("Klaida trinant vartotoją: $e");
      return false;
    }
  }

  ///
  Future<bool> isUsernameAvailable(String username) async {
    try {
      var doc = await userCollection.doc(username).get();
      return !doc.exists;
    } catch (e) {
      print("Toks username jau užimtas: $e");
      return false;
    }
  }
}
