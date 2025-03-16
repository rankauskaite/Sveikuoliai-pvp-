import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'user_services.dart';

//FIREBASE AUTHENTICATION PRISIJUNGIMAS

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService(); // UserService instance

  // Registracija
  Future<User?> registerWithEmail(
      String email, String password, String username, String name) async {
    try {
      // Pirmiausia, užregistruojame vartotoją su el. paštu ir slaptažodžiu
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        // Sukuriame vartotojo modelį
        UserModel newUser = UserModel(
          username: username,
          name: name,
          email: email,
          password:
              password, //reiketu nesaugot duombazej nes uzsiregistravus jis saugomas firebase authentication ir yra sifruojamas bet saugom kad zinot kaip prisijungt pacios
          role: "user",
          notifications: true,
          darkMode: false,
          menstrualLength: 7,
          version: "free",
          createdAt: DateTime.now(),
        );

        // Išsaugome vartotojo duomenis į Firestore
        await _userService.createUserEntry(newUser); // Išsaugoti į Firestore

        // Grąžiname užregistruotą vartotoją
        return user;
      }
    } catch (e) {
      print("Klaida registruojant: $e");
      return null;
    }
  }

  // Prisijungimas
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Klaida prisijungiant: $e");
      return null;
    }
  }

  // Atsijungimas
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Gauti dabartinį vartotoją
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Gauti vartotojo duomenis pagal jo UID
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    var userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc.data();
    }
    return null;
  }
}
