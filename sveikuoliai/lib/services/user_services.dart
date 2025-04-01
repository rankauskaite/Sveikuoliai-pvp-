import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // create
  Future<bool> createUserEntry(UserModel user) async {
    try {
      DocumentSnapshot doc = await userCollection.doc(user.username).get();
      if (doc.exists) return false; // Jei username jau užimtas, false

      // 1. useris Firebase authentification
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      // 2. useris į duombazę
      await userCollection.doc(user.username).set(user.toJson());
      return true;
    } catch (e) {
      print("Klaida kuriant vartotojo įrašą: $e");
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

  Future<bool> updateUserData(
      String username, String name, String email, String version) async {
    try {
      Map<String, dynamic> dataToUpdate = {};

      // Jei vardas pakeistas, pridedame jį į atnaujinimo laukus
      if (name.isNotEmpty) {
        dataToUpdate['name'] = name;
      }

      // Jei el. paštas pakeistas, pridedame jį į atnaujinimo laukus
      if (email.isNotEmpty) {
        dataToUpdate['email'] = email;
      }

      // Jei versija pakeista, pridedame ją į atnaujinimo laukus
      if (version.isNotEmpty) {
        dataToUpdate['version'] = version;
      }

      // Jei yra ką atnaujinti
      if (dataToUpdate.isNotEmpty) {
        await userCollection.doc(username).update(dataToUpdate);
        return true;
      }

      return false; // Jeigu nėra ką atnaujinti
    } catch (e) {
      print("Klaida atnaujinant vartotoją: $e");
      return false;
    }
  }

  // Funkcija, kuri atnaujina tik nustatymus (pranešimus, temą ir mėnesinių trukmę)
  Future<bool> updateSettings(String username, bool notifications,
      bool darkMode, int menstrualLength) async {
    try {
      // Sukuriame žemėlapį su tik nustatymais
      Map<String, dynamic> settingsData = {
        'notifications': notifications,
        'darkMode': darkMode,
        'menstrualLength': menstrualLength,
      };

      // Atnaujiname tik nustatymų laukus Firestore duomenų bazėje
      await userCollection.doc(username).update(settingsData);
      return true;
    } catch (e) {
      print("Klaida atnaujinant nustatymus: $e");
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

  ///
}
