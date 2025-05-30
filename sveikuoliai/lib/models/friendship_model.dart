import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/user_model.dart';

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
      'id': id,
      'user1': user1,
      'user2': user2,
      'status': status,
      'createdAt': createdAt.toIso8601String(), // Konvertuojame į String
    };
  }

  /// i objekta
  factory Friendship.fromJson(String id, Map<String, dynamic> json) {
    return Friendship(
      id: json['id'],
      user1: json['user1'] ?? '',
      user2: json['user2'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  /// draugystes id is useriu
  static String generateFriendshipId(String user1, String user2) {
    List<String> sortedUsers = [user1, user2]
      ..sort(); // Surikiuoja abėcėlės tvarka
    return "${sortedUsers[0]}_${sortedUsers[1]}";
  }
}

class FriendshipModel {
  Friendship friendship; // Draugystės objektas
  UserModel friend;

  FriendshipModel({
    required this.friendship,
    required this.friend,
  });

  Map<String, dynamic> toJson() {
    return {
      'friendship': friendship.toJson(),
      'friend': friend.toJson(),
    };
  }

  factory FriendshipModel.fromJson(Map<String, dynamic> json) {
    return FriendshipModel(
      friendship: Friendship.fromJson(
          json['id']?.toString() ?? '',
          (json['friendship'] is Map<String, dynamic>)
              ? json['friendship']
              : {} as Map<String, dynamic>),
      friend: UserModel.fromJson(
          json['friend']?['username']?.toString() ?? '',
          (json['friend'] is Map<String, dynamic>)
              ? json['friend']
              : {} as Map<String, dynamic>),
    );
  }
}
