// lib/services/doubt_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/mocktest_model.dart';

class DoubtService extends GetxService {
  static DoubtService get instance => Get.find<DoubtService>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> hasSubmittedToday(String studentId) async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _db
        .collection('doubts')
        .where('studentId', isEqualTo: studentId)
        .where('submittedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('submittedAt', isLessThan: Timestamp.fromDate(end))
        .get();

    return snap.docs.isNotEmpty;
  }

  Future<void> submitDoubt(DoubtModel doubt) async {
    await _db.collection('doubts').add(doubt.toFirestore());
  }

  Future<void> answerDoubt(String doubtId, String answer) async {
    await _db.collection('doubts').doc(doubtId).update({
      'answer': answer,
      'isAnswered': true,
    });
  }

  Stream<List<DoubtModel>> getStudentDoubts(String studentId) {
    return _db
        .collection('doubts')
        .where('studentId', isEqualTo: studentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DoubtModel.fromFirestore).toList());
  }

  Stream<List<DoubtModel>> getAllPendingDoubts() {
    return _db
        .collection('doubts')
        .where('isAnswered', isEqualTo: false)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DoubtModel.fromFirestore).toList());
  }
}
