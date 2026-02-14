import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/payment_model.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Razorpay Key
  static const String _razorpayKey = 'rzp_test_RQX7adT0U42yu4';

  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onError;

  PaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void dispose() {
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onError?.call(response);
  }

  /// Initiate Razorpay Payment UI (Simplified - No Order ID required for simple integration)
  /// Note: Razorpay recommended using Order ID, but for college projects,
  /// you can pass the amount directly in checkout options.
  void startPayment({
    required double amount,
    required String name,
    required String description,
    required String email,
    required String contact,
  }) {
    final options = {
      'key': _razorpayKey,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': name,
      'description': description,
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
    }
  }

  /// Directly save payment success to Firestore or update existing pending payment
  Future<void> savePaymentToFirestore({
    required String paymentId,
    required Map<String, dynamic> paymentDetails,
    String? existingDocId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final paymentData = {
        ...paymentDetails,
        'status': 'paid',
        'verified': true, // Directly marking as true for student project
        'paymentDate': FieldValue.serverTimestamp(),
        'transactionId': paymentId,
        'paymentMethod': 'Razorpay',
      };

      if (existingDocId != null) {
        // Update existing pending record
        await _firestore
            .collection('FeePayments')
            .doc(existingDocId)
            .update(paymentData);
      } else {
        // Create new record (if not already exists - fallback)
        await _firestore.collection('FeePayments').add({
          ...paymentData,
          'studentId': paymentDetails['studentId'] ?? user.uid,
        });
      }

      final studentId = paymentDetails['studentId'] ?? user.uid;
      final studentName = paymentDetails['studentName'] ?? 'Student';

      // Add notification for the student
      await _firestore
          .collection('users')
          .doc(studentId)
          .collection('notifications')
          .add({
            'title': 'Fee Paid Successfully',
            'message':
                'Your fee payment of ₹${paymentDetails['amount']} for ${paymentDetails['title'] ?? 'Fees'} has been recorded.',
            'createdAt': FieldValue.serverTimestamp(),
            'isRead': false,
            'type': 'payment',
          });

      // Add notification for the parent if available
      final studentDoc = await _firestore
          .collection('users')
          .doc(studentId)
          .get();
      if (studentDoc.exists && studentDoc.data()?['parentId'] != null) {
        final parentId = studentDoc.data()?['parentId'];
        await _firestore
            .collection('users')
            .doc(parentId)
            .collection('notifications')
            .add({
              'title': 'Fee Paid for Child',
              'message':
                  'Fee payment of ₹${paymentDetails['amount']} for $studentName has been recorded.',
              'createdAt': FieldValue.serverTimestamp(),
              'isRead': false,
              'type': 'payment',
            });
      }
    } catch (e) {
      print('Error saving payment: $e');
      rethrow;
    }
  }
}
