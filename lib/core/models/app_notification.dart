import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  announcement,
  assignment,
  exam,
  fee,
  attendance,
  alert,
  general,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String senderId;
  final String senderName;
  final String? targetId; // specific user uid, classId, or null for all
  final String
  targetType; // 'individual', 'class', 'all_students', 'all_parents', 'all'
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.senderId,
    required this.senderName,
    this.targetId,
    required this.targetType,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromFirestore(Map<String, dynamic> data, String id) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: _parseType(data['type']),
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      targetId: data['targetId'],
      targetType: data['targetType'] ?? 'all',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'senderId': senderId,
      'senderName': senderName,
      'targetId': targetId,
      'targetType': targetType,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  static NotificationType _parseType(String? type) {
    return NotificationType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NotificationType.general,
    );
  }
}
