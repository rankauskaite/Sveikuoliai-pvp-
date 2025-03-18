import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String username; // Unikalus ID, pasirenkamas naudotojo
  String name;
  String password;
  String role;
  bool notifications;
  bool darkMode;
  int menstrualLength;
  String email;
  String version;
  String? iconUrl;
  DateTime createdAt;

  UserModel({
    required this.username,
    required this.name,
    required this.password,
    required this.role,
    required this.notifications,
    required this.darkMode,
    required this.menstrualLength,
    required this.email,
    required this.createdAt,
    required this.version,
    this.iconUrl,
  });

  /// Konvertuoja į JSON formatą Firestore išsaugojimui
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'version': version,
      'password': password,
      'role': role,
      'notifications': notifications,
      'darkMode': darkMode,
      'menstrualLength': menstrualLength,
      'iconUrl': iconUrl,
      'createdAt': Timestamp.fromDate(createdAt), // Firestore Timestamp
    };
  }

  /// Sukuria `UserModel` iš Firestore dokumento
  factory UserModel.fromJson(String username, Map<String, dynamic> json) {
    return UserModel(
      username: username, // Dokumento ID kaip username
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      iconUrl: json['iconUrl'],
      version: json['version'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // Apsauga nuo null
      role: json['role'] ?? '',
      notifications: json['notifications'] ?? false,
      darkMode: json['darkMode'] ?? false,
      menstrualLength: json['menstrualLength'] ?? 0,
      password: json['password'] ?? '',
    );
  }

  //
  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .set(toJson());
  }

  // ar unikalus username
  static Future<bool> isUsernameAvailable(String username) async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    return !doc.exists;
  }

  //
  static Future<UserModel?> getUser(String username) async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(username, doc.data()!);
    }
    return null;
  }
}

class UserModelMod {
  String username; // Unikalus ID, pasirenkamas naudotojo
  String name;
  String email;

  UserModelMod({
    required this.username,
    required this.name,
    required this.email,
  });
}
