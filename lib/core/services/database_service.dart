import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/exam_model.dart';
import '../models/assignment_model.dart';
import '../models/payment_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // MARK: - Users
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(user.toFirestore());
  }

  // MARK: - Students
  Stream<List<UserModel>> getStudentsByClass(String classId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // MARK: - Exams
  Future<void> recordExamAttendance(ExamAttendance attendance) async {
    await _firestore.collection('ExamAttendance').add(attendance.toFirestore());
  }

  Stream<List<ExamAttendance>> getExamAttendanceForTeacher(String classId) {
    return _firestore
        .collection('ExamAttendance')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExamAttendance.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // MARK: - Assignments
  Future<void> submitAssignment(AssignmentSubmission submission) async {
    await _firestore
        .collection('AssignmentSubmissions')
        .add(submission.toFirestore());
  }

  Stream<List<AssignmentSubmission>> getSubmissionsForAssignment(
    String assignmentId,
  ) {
    return _firestore
        .collection('AssignmentSubmissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AssignmentSubmission.fromFirestore(doc.data(), doc.id),
              )
              .toList(),
        );
  }

  Future<void> gradeSubmission(
    String submissionId,
    String grade,
    String feedback,
  ) async {
    await _firestore
        .collection('AssignmentSubmissions')
        .doc(submissionId)
        .update({
          'grade': grade,
          'feedback': feedback,
          'gradedAt': FieldValue.serverTimestamp(),
        });
  }

  // MARK: - Payments
  Future<void> recordPayment(Payment payment) async {
    await _firestore.collection('FeePayments').add(payment.toFirestore());
  }

  Stream<List<Payment>> getStudentPayments(String studentId) {
    return _firestore
        .collection('FeePayments')
        .where('studentId', isEqualTo: studentId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Payment.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await _firestore.collection('FeePayments').doc(paymentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
