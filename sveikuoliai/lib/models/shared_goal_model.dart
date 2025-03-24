import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/category_enum.dart'; // Enum įtraukimas

class SharedGoal {
  String id;
  DateTime startDate;
  DateTime endDate;
  int points;
  bool isCountable;
  CategoryType category;
  int endPoints;
  String user1Id;
  String user2Id; 
  String plantId;
  String goalTypeId;

  SharedGoal({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.points,
    required this.isCountable,
    required this.category,
    required this.endPoints,
    required this.user1Id,
    required this.user2Id,
    required this.plantId,
    required this.goalTypeId,
  });

  /// Konvertavimas į JSON
  Map<String, dynamic> toJson() {
    return {
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'points': points,
      'isCountable': isCountable,
      'category': category.toJson(), // Enum į string
      'endPoints': endPoints,
      'user1Id': user1Id,
      'user2Id': user2Id, 
      'plantId': plantId,
      'goalTypeId': goalTypeId,
    };
  }

  /// Konvertavimas iš JSON
  factory SharedGoal.fromJson(String id, Map<String, dynamic> json) {
    return SharedGoal(
      id: id,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      points: json['points'] ?? 0,
      isCountable: json['isCountable'] ?? false,
      category: CategoryTypeExtension.fromJson(json['category'] ?? ''), // Enum iš string
      endPoints: json['endPoints'] ?? 0,
      user1Id: json['user1Id'] ?? '',
      user2Id: json['user2Id'] ?? '', // Buvo `user2ID`
      plantId: json['plantId'] ?? '',
      goalTypeId: json['goalTypeId'] ?? '',
    );
  }
}
