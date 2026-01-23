import 'package:cloud_firestore/cloud_firestore.dart';

class Exam {
  final String id;
  final String title;
  final String subject;
  final String classId;
  final DateTime date;
  final String duration;
  final int totalMarks;
  final List<Question> questions;

  Exam({
    required this.id,
    required this.title,
    required this.subject,
    required this.classId,
    required this.date,
    required this.duration,
    required this.totalMarks,
    required this.questions,
  });

  factory Exam.fromFirestore(Map<String, dynamic> data, String id) {
    return Exam(
      id: id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      classId: data['classId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      duration: data['duration'] ?? '',
      totalMarks: data['totalMarks'] ?? 0,
      questions: (data['questions'] as List? ?? [])
          .map((q) => Question.fromMap(q))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subject': subject,
      'classId': classId,
      'date': Timestamp.fromDate(date),
      'duration': duration,
      'totalMarks': totalMarks,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}

class ExamAttendance {
  final String id;
  final String examId;
  final String studentId;
  final String studentName;
  final DateTime attendedAt;
  final int score;
  final bool isCompleted;

  ExamAttendance({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.attendedAt,
    required this.score,
    this.isCompleted = true,
  });

  factory ExamAttendance.fromFirestore(Map<String, dynamic> data, String id) {
    return ExamAttendance(
      id: id,
      examId: data['examId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      attendedAt: (data['attendedAt'] as Timestamp).toDate(),
      score: data['score'] ?? 0,
      isCompleted: data['isCompleted'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'examId': examId,
      'studentId': studentId,
      'studentName': studentName,
      'attendedAt': FieldValue.serverTimestamp(),
      'score': score,
      'isCompleted': isCompleted,
    };
  }
}
