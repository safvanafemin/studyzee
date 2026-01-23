import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final int month; // 1-12
  final int year;
  final double amount;
  final String status; // 'paid', 'pending', 'overdue'
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? transactionId;
  final String? receiptNumber;
  final String? razorpayOrderId;
  final String? razorpaySignature;
  final bool verified;

  Payment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.month,
    required this.year,
    required this.amount,
    required this.status,
    this.paymentDate,
    this.paymentMethod,
    this.transactionId,
    this.receiptNumber,
    this.razorpayOrderId,
    this.razorpaySignature,
    this.verified = false,
  });

  factory Payment.fromFirestore(Map<String, dynamic> data, String id) {
    return Payment(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      classId: data['classId'] ?? '',
      month: data['month'] ?? 1,
      year: data['year'] ?? 2024,
      amount: (data['amount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentDate: data['paymentDate'] != null
          ? (data['paymentDate'] as Timestamp).toDate()
          : null,
      paymentMethod: data['paymentMethod'],
      transactionId: data['transactionId'],
      receiptNumber: data['receiptNumber'],
      razorpayOrderId: data['razorpayOrderId'],
      razorpaySignature: data['razorpaySignature'],
      verified: data['verified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'month': month,
      'year': year,
      'amount': amount,
      'status': status,
      'verified': verified,
      if (paymentDate != null) 'paymentDate': Timestamp.fromDate(paymentDate!),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (transactionId != null) 'transactionId': transactionId,
      if (receiptNumber != null) 'receiptNumber': receiptNumber,
      if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
      if (razorpaySignature != null) 'razorpaySignature': razorpaySignature,
    };
  }
}
