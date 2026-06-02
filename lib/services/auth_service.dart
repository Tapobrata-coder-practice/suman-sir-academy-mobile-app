// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';
import '../config/routes.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Rx<User?> currentUser = Rx<User?>(null);
  final Rx<StudentModel?> studentData = Rx<StudentModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAdmin = false.obs;

  String? _verificationId;
  int? _resendToken;

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(_auth.authStateChanges());
    ever(currentUser, _handleAuthChange);
  }

  void _handleAuthChange(User? user) {
    if (user != null) {
      _loadStudentData(user.uid);
    } else {
      studentData.value = null;
      isAdmin.value = false;
    }
  }

  Future<void> _loadStudentData(String uid) async {
    try {
      // Check if admin
      final adminDoc = await _db.collection('admins').doc(uid).get();
      if (adminDoc.exists) {
        isAdmin.value = true;
      }

      final doc = await _db.collection('students').doc(uid).get();
      if (doc.exists) {
        studentData.value = StudentModel.fromFirestore(doc);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    isLoading.value = true;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          String msg = 'Verification failed. Please try again.';
          if (e.code == 'invalid-phone-number') {
            msg = 'Invalid phone number. Please check and try again.';
          } else if (e.code == 'too-many-requests') {
            msg = 'Too many requests. Please try again later.';
          }
          onError(msg);
        },
        codeSent: (String verificationId, int? resendToken) {
          isLoading.value = false;
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      isLoading.value = false;
      onError('Something went wrong. Please try again.');
    }
  }

  Future<void> verifyOtp({
    required String otp,
    required String name,
    required String phone,
    required Function onSuccess,
    required Function(String error) onError,
  }) async {
    if (_verificationId == null) {
      onError('Verification session expired. Please request OTP again.');
      return;
    }

    isLoading.value = true;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signInWithCredential(credential, name: name, phone: phone);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String msg = 'Invalid OTP. Please try again.';
      if (e.code == 'session-expired') {
        msg = 'OTP session expired. Please request a new OTP.';
      }
      onError(msg);
    } catch (e) {
      isLoading.value = false;
      onError('Something went wrong. Please try again.');
    }
  }

  Future<void> _signInWithCredential(
    PhoneAuthCredential credential, {
    String? name,
    String? phone,
  }) async {
    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user!;

    final doc = await _db.collection('students').doc(user.uid).get();
    if (!doc.exists && name != null) {
      final student = StudentModel(
        uid: user.uid,
        name: name,
        phone: phone ?? user.phoneNumber ?? '',
        createdAt: DateTime.now(),
      );
      await _db.collection('students').doc(user.uid).set(student.toFirestore());
      studentData.value = student;
    } else if (doc.exists) {
      studentData.value = StudentModel.fromFirestore(doc);
    }

    isLoading.value = false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    studentData.value = null;
    isAdmin.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  bool get isLoggedIn => currentUser.value != null;
  String get userId => currentUser.value?.uid ?? '';
  String get userName => studentData.value?.name ?? '';
  bool get isBlocked => studentData.value?.isBlocked ?? false;

  Future<void> refreshStudentData() async {
    if (userId.isNotEmpty) {
      await _loadStudentData(userId);
    }
  }
}
