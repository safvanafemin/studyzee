import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send notification to a specific user
  Future<void> sendIndividualNotification({
    required String recipientId,
    required String title,
    required String message,
    required NotificationType type,
    required String senderId,
    required String senderName,
  }) async {
    final notification = AppNotification(
      id: '',
      title: title,
      message: message,
      type: type,
      senderId: senderId,
      senderName: senderName,
      targetId: recipientId,
      targetType: 'individual',
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(recipientId)
        .collection('notifications')
        .add(notification.toFirestore());
  }

  // Send notification to all students in a class
  Future<void> sendClassNotification({
    required String classId,
    required String title,
    required String message,
    required NotificationType type,
    required String senderId,
    required String senderName,
  }) async {
    final studentsSnapshot = await _firestore
        .collection('Students')
        .where('classId', isEqualTo: classId)
        .get();

    final batch = _firestore.batch();

    for (var doc in studentsSnapshot.docs) {
      final notification = AppNotification(
        id: '',
        title: title,
        message: message,
        type: type,
        senderId: senderId,
        senderName: senderName,
        targetId: classId,
        targetType: 'class',
        createdAt: DateTime.now(),
      );

      final ref = _firestore
          .collection('users')
          .doc(doc.id)
          .collection('notifications')
          .doc();
      batch.set(ref, notification.toFirestore());

      // Also send to parent if student has a parentId
      final studentData = doc.data();
      if (studentData['parentId'] != null) {
        final parentRef = _firestore
            .collection('users')
            .doc(studentData['parentId'])
            .collection('notifications')
            .doc();
        batch.set(parentRef, notification.toFirestore());
      }
    }

    await batch.commit();
  }

  // Send notification to all roles (Students, Parents, or both)
  Future<void> sendRoleNotification({
    required String role, // 'Student', 'Parent', or 'Both'
    required String title,
    required String message,
    required NotificationType type,
    required String senderId,
    required String senderName,
  }) async {
    Query query = _firestore.collection('users');
    if (role != 'Both') {
      query = query.where('role', isEqualTo: role);
    }

    final usersSnapshot = await query.get();
    final batch = _firestore.batch();

    for (var doc in usersSnapshot.docs) {
      final notification = AppNotification(
        id: '',
        title: title,
        message: message,
        type: type,
        senderId: senderId,
        senderName: senderName,
        targetType: role.toLowerCase(),
        createdAt: DateTime.now(),
      );

      final ref = _firestore
          .collection('users')
          .doc(doc.id)
          .collection('notifications')
          .doc();
      batch.set(ref, notification.toFirestore());
    }

    await batch.commit();
  }

  // Stream notifications for a user
  Stream<List<AppNotification>> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Mark as read
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    final unread = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
