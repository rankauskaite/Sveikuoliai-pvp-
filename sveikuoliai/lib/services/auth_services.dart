// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'user_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  Future<User?> registerWithGoogle(String username) async {
    try {
      // Pirmiausia atlikime prisijungimą su Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null)
        return null; // Jei vartotojas atsisako prisijungimo

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Pabandykite prisijungti su Google ir sukurti vartotoją
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        UserModel newUser = UserModel(
          username: username,
          name: '${user.displayName}',
          password: '',
          email: '${user.email}',
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
      print("Klaida registruojant su Google: $e");
    }
    return null;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    User? user = userCredential.user;
    if (user != null) {
      UserModel? userData = await _userService.getUserEntryByEmail(user.email!);
      if (userData != null) {
        await _saveUserToSession(userData);
      }
    }
    return userCredential;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    await _storage.deleteAll();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print("Slaptažodžio priminimo laiškas išsiųstas: $email");
    } catch (e) {
      print("Klaida siunčiant priminimo laišką: $e");
      rethrow;
    }
  }

  Future<void> _saveUserToSession(UserModel user) async {
    await _storage.write(key: "username", value: user.username);
    await _storage.write(key: "name", value: user.name);
    await _storage.write(key: "email", value: user.email);
    await _storage.write(key: "version", value: user.version);
    await _storage.write(
        key: "date", value: DateTime.now().toIso8601String().split('T').first);
  }

  Future<void> updateUserSession(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<Map<String, String?>> getSessionUser() async {
    return {
      "username": await _storage.read(key: "username"),
      "name": await _storage.read(key: "name"),
      "email": await _storage.read(key: "email"),
      "version": await _storage.read(key: "version"),
      "date": await _storage.read(key: "date"),
    };
  }
}
