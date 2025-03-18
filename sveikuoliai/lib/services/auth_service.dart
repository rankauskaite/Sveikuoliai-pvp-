import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'user_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<User?> registerWithEmail(
      String email, String password, String username, String name) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        UserModel newUser = UserModel(
          username: username,
          name: name,
          password: password,
          email: email,
          role: "user",
          notifications: true,
          darkMode: false,
          menstrualLength: 7,
          version: "free",
          createdAt: DateTime.now(),
        );
        await _userService.createUserEntry(newUser);
        await _saveUserToSession(newUser);
        return user;
      }
    } catch (e) {
      print("Klaida registruojant: $e");
    }
    return null;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        UserModel? userData = await _userService.getUserEntryByEmail(email);
        if (userData != null) {
          await _saveUserToSession(userData);
        }
      }
      return user;
    } catch (e) {
      print("Klaida prisijungiant: $e");
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.deleteAll();
  }

  Future<void> _saveUserToSession(UserModel user) async {
    await _storage.write(key: "username", value: user.username);
    await _storage.write(key: "name", value: user.name);
    await _storage.write(key: "email", value: user.email);
  }

  Future<Map<String, String?>> getSessionUser() async {
    return {
      "username": await _storage.read(key: "username"),
      "name": await _storage.read(key: "name"),
      "email": await _storage.read(key: "email"),
    };
  }
}
