import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String classId;
  final DateTime dueDate;
  final DateTime createdAt;
  final String teacherId;
  final String? attachmentUrl;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.classId,
    required this.dueDate,
    required this.createdAt,
    required this.teacherId,
    this.attachmentUrl,
  });

  factory Assignment.fromFirestore(Map<String, dynamic> data, String id) {
    return Assignment(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subject: data['subject'] ?? '',
      classId: data['classId'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      teacherId: data['teacherId'] ?? '',
      attachmentUrl: data['attachmentUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'classId': classId,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': FieldValue.serverTimestamp(),
      'teacherId': teacherId,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
    };
  }
}

class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final DateTime submittedAt;
  final String fileUrl;
  final String? grade;
  final String? feedback;

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
    required this.fileUrl,
    this.grade,
    this.feedback,
  });

  factory AssignmentSubmission.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return AssignmentSubmission(
      id: id,
      assignmentId: data['assignmentId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      fileUrl: data['fileUrl'] ?? '',
      grade: data['grade'],
      feedback: data['feedback'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'submittedAt': FieldValue.serverTimestamp(),
      'fileUrl': fileUrl,
      if (grade != null) 'grade': grade,
      if (feedback != null) 'feedback': feedback,
    };
  }
}
