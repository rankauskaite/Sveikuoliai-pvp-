import 'package:cloud_firestore/cloud_firestore.dart';

class MenstrualCycle {
  String id;
  String userId;
  DateTime startDate;
  DateTime endDate;

  MenstrualCycle({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  // i json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }

  // is json
  factory MenstrualCycle.fromJson(String id, Map<String, dynamic> json) {
    return MenstrualCycle(
      id: id,
      userId: json['userId'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(), // -> DateTime
      endDate: (json['endDate'] as Timestamp).toDate(), // -> DateTime
    );
  }
}
