import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registracija
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
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

  // Tikrinti ar vartotojas prisijungęs
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
