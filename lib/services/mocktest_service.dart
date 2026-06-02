// lib/services/mocktest_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/mocktest_model.dart';

class MocktestService extends GetxService {
  static MocktestService get instance => Get.find<MocktestService>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MocktestModel>> getActiveTests() {
    return _db
        .collection('mocktests')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(MocktestModel.fromFirestore).toList());
  }

  Future<void> addTest(MocktestModel test) async {
    await _db.collection('mocktests').add(test.toFirestore());
  }

  Future<void> updateTest(String id, Map<String, dynamic> data) async {
    await _db.collection('mocktests').doc(id).update(data);
  }

  Future<void> deleteTest(String id) async {
    await _db.collection('mocktests').doc(id).delete();
  }

  Future<void> submitResult(TestResultModel result) async {
    await _db.collection('testResults').add(result.toFirestore());
  }

  Stream<List<TestResultModel>> getStudentResults(String studentId) {
    return _db
        .collection('testResults')
        .where('studentId', isEqualTo: studentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TestResultModel.fromFirestore).toList());
  }

  Stream<List<TestResultModel>> getUncheckedWrittenTests() {
    return _db
        .collection('testResults')
        .where('testType', isEqualTo: 'written')
        .where('isChecked', isEqualTo: false)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TestResultModel.fromFirestore).toList());
  }

  Future<void> gradeWrittenTest(String resultId, int marksObtained) async {
    await _db.collection('testResults').doc(resultId).update({
      'marksObtained': marksObtained,
      'isChecked': true,
    });
  }
}
