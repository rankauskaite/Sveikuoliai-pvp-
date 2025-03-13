import 'package:cloud_firestore/cloud_firestore.dart';

class MenstrualCycle {
  String id;
  String userId;
  DateTime startDate;

  MenstrualCycle({
    required this.id,
    required this.userId,
    required this.startDate,
  });

  // i json
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate), 
    };
  }

  // is json
  factory MenstrualCycle.fromJson(String id, Map<String, dynamic> json) {
    return MenstrualCycle(
      id: id,
      userId: json['userId'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(), // -> DateTime
    );
  }
}
