import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  String id; 
  String userId; 
  String text;
  bool isRead;
  DateTime date;

  AppNotification({
    required this.id,
    required this.userId,
    required this.text,
    this.isRead = false, // default false
    required this.date,
  });

  // i json
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'text': text,
      'isRead': isRead,
      'date': Timestamp.fromDate(date),
    };
  }

  // is json
  factory AppNotification.fromJson(String id, Map<String, dynamic> json) {
    return AppNotification(
      id: id,
      userId: json['userId'] ?? '',
      text: json['text'] ?? '',
      isRead: json['isRead'] ?? false, 
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(), 
    );
  }
}
