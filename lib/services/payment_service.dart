// lib/services/payment_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/mocktest_model.dart';
import '../services/auth_service.dart';

class PaymentService extends GetxService {
  static PaymentService get instance => Get.find<PaymentService>();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Razorpay _razorpay;

  // IMPORTANT: Replace with your actual Razorpay test/live keys
  static const String _razorpayKeyId = 'rzp_test_YOUR_KEY_HERE';

  final RxBool isLoading = false.obs;
  Function(String paymentId, String courseId)? onPaymentSuccess;
  Function(String error)? onPaymentError;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void initiatePayment({
    required String courseId,
    required String courseName,
    required double amount,
    required Function(String paymentId, String courseId) onSuccess,
    required Function(String error) onError,
  }) {
    final student = AuthService.instance.studentData.value;
    if (student == null) return;

    onPaymentSuccess = onSuccess;
    onPaymentError = onError;

    final options = {
      'key': _razorpayKeyId,
      'amount': (amount * 100).toInt(), // in paise
      'name': 'Suman Sir English Academy',
      'description': 'Course: $courseName',
      'prefill': {
        'contact': student.phone,
        'name': student.name,
      },
      'external': {
        'wallets': ['paytm', 'phonepe', 'upi']
      },
      'theme': {'color': '#1A56DB'},
      'notes': {
        'courseId': courseId,
        'studentId': student.uid,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      onError('Failed to open payment. Please try again.');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final student = AuthService.instance.studentData.value;
    if (student == null) return;

    isLoading.value = true;
    try {
      // Save payment record
      final courseId = response.data?['courseId'] ?? '';

      final payment = PaymentModel(
        id: '',
        studentId: student.uid,
        studentName: student.name,
        courseId: courseId,
        courseName: '',
        amount: 0,
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        status: 'success',
        createdAt: DateTime.now(),
      );

      await _db.collection('payments').add(payment.toFirestore());

      // Unlock course for student
      await _db.collection('students').doc(student.uid).update({
        'purchasedCourses': FieldValue.arrayUnion([courseId]),
      });

      await AuthService.instance.refreshStudentData();

      isLoading.value = false;
      onPaymentSuccess?.call(response.paymentId ?? '', courseId);
    } catch (e) {
      isLoading.value = false;
      onPaymentError?.call('Payment recorded but course unlock failed. Contact support.');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isLoading.value = false;
    String msg = 'Payment failed. Please try again.';
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      msg = 'Payment cancelled.';
    }
    onPaymentError?.call(msg);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
  }

  Future<void> approvePaymentManually({
    required String studentId,
    required String courseId,
  }) async {
    await _db.collection('students').doc(studentId).update({
      'purchasedCourses': FieldValue.arrayUnion([courseId]),
    });

    await _db.collection('payments').add({
      'studentId': studentId,
      'courseId': courseId,
      'status': 'success',
      'isManualApproval': true,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<List<PaymentModel>> getStudentPayments(String studentId) {
    return _db
        .collection('payments')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PaymentModel.fromFirestore).toList());
  }

  Stream<List<PaymentModel>> getAllPayments() {
    return _db
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PaymentModel.fromFirestore).toList());
  }
}
