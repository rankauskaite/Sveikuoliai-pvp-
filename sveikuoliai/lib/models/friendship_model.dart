import 'package:cloud_firestore/cloud_firestore.dart';

class Friendship {
  String id; // Unikalus ID (user1_user2)
  String user1; // drauags1
  String user2; // draugas2
  String status; // "pending", "accepted", "declined"
  DateTime createdAt; 
  Friendship({
    required this.id,
    required this.user1,
    required this.user2,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user1': user1,
      'user2': user2,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// i objekta
  factory Friendship.fromJson(String id, Map<String, dynamic> json) {
    return Friendship(
      id: id,
      user1: json['user1'] ?? '',
      user2: json['user2'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// draugystes id is useriu
  static String generateFriendshipId(String user1, String user2) {
    List<String> sortedUsers = [user1, user2]..sort(); // Surikiuoja abėcėlės tvarka
    return "${sortedUsers[0]}_${sortedUsers[1]}"; 
}
}