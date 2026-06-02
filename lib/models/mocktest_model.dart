// lib/models/mocktest_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum TestType { mcq, written }

class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final int marks;
  final String? imageUrl;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.marks = 1,
    this.imageUrl,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> data) {
    return QuestionModel(
      id: data['id'] ?? '',
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctOptionIndex: data['correctOptionIndex'] ?? 0,
      marks: data['marks'] ?? 1,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'question': question,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'marks': marks,
        'imageUrl': imageUrl,
      };
}

class MocktestModel {
  final String id;
  final String title;
  final String? description;
  final TestType type;
  final List<QuestionModel> questions;
  final int totalMarks;
  final int durationMinutes;
  final String? courseId;
  final String? batchId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final String? pdfUrl; // for written tests

  MocktestModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.questions = const [],
    required this.totalMarks,
    required this.durationMinutes,
    this.courseId,
    this.batchId,
    this.isActive = true,
    required this.createdAt,
    this.scheduledAt,
    this.pdfUrl,
  });

  factory MocktestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MocktestModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      type: TestType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TestType.mcq,
      ),
      questions: (data['questions'] as List? ?? [])
          .map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
          .toList(),
      totalMarks: data['totalMarks'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 30,
      courseId: data['courseId'],
      batchId: data['batchId'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
      pdfUrl: data['pdfUrl'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'type': type.name,
        'questions': questions.map((q) => q.toMap()).toList(),
        'totalMarks': totalMarks,
        'durationMinutes': durationMinutes,
        'courseId': courseId,
        'batchId': batchId,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
        'pdfUrl': pdfUrl,
      };
}

class TestResultModel {
  final String id;
  final String studentId;
  final String studentName;
  final String testId;
  final TestType testType;
  final Map<String, int> answers; // questionId → selectedOption
  final int marksObtained;
  final int totalMarks;
  final String? answerSheetUrl; // for written
  final bool isChecked; // for written
  final DateTime submittedAt;
  final int timeTakenSeconds;

  TestResultModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.testId,
    required this.testType,
    this.answers = const {},
    required this.marksObtained,
    required this.totalMarks,
    this.answerSheetUrl,
    this.isChecked = false,
    required this.submittedAt,
    required this.timeTakenSeconds,
  });

  factory TestResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestResultModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      testId: data['testId'] ?? '',
      testType: TestType.values.firstWhere(
        (e) => e.name == data['testType'],
        orElse: () => TestType.mcq,
      ),
      answers: Map<String, int>.from(data['answers'] ?? {}),
      marksObtained: data['marksObtained'] ?? 0,
      totalMarks: data['totalMarks'] ?? 0,
      answerSheetUrl: data['answerSheetUrl'],
      isChecked: data['isChecked'] ?? false,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeTakenSeconds: data['timeTakenSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'studentId': studentId,
        'studentName': studentName,
        'testId': testId,
        'testType': testType.name,
        'answers': answers,
        'marksObtained': marksObtained,
        'totalMarks': totalMarks,
        'answerSheetUrl': answerSheetUrl,
        'isChecked': isChecked,
        'submittedAt': Timestamp.fromDate(submittedAt),
        'timeTakenSeconds': timeTakenSeconds,
      };

  double get percentage => totalMarks > 0 ? (marksObtained / totalMarks) * 100 : 0;
  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }
}

// lib/models/notification_model.dart
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // class_reminder, payment, exam, holiday, announcement
  final bool isImportant;
  final String? targetBatchId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isImportant = false,
    this.targetBatchId,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'announcement',
      isImportant: data['isImportant'] ?? false,
      targetBatchId: data['targetBatchId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'body': body,
        'type': type,
        'isImportant': isImportant,
        'targetBatchId': targetBatchId,
        'createdAt': Timestamp.fromDate(createdAt),
        'isRead': isRead,
      };
}

// lib/models/doubt_model.dart
class DoubtModel {
  final String id;
  final String studentId;
  final String studentName;
  final String studentPhone;
  final String question;
  final String? answer;
  final String? courseId;
  final DateTime submittedAt;
  final bool isAnswered;

  DoubtModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentPhone,
    required this.question,
    this.answer,
    this.courseId,
    required this.submittedAt,
    this.isAnswered = false,
  });

  factory DoubtModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoubtModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentPhone: data['studentPhone'] ?? '',
      question: data['question'] ?? '',
      answer: data['answer'],
      courseId: data['courseId'],
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAnswered: data['isAnswered'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'studentId': studentId,
        'studentName': studentName,
        'studentPhone': studentPhone,
        'question': question,
        'answer': answer,
        'courseId': courseId,
        'submittedAt': Timestamp.fromDate(submittedAt),
        'isAnswered': isAnswered,
      };
}

// lib/models/payment_model.dart
class PaymentModel {
  final String id;
  final String studentId;
  final String studentName;
  final String courseId;
  final String courseName;
  final double amount;
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String status; // success, failed, pending
  final DateTime createdAt;
  final bool isManualApproval;

  PaymentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseName,
    required this.amount,
    this.razorpayPaymentId = '',
    this.razorpayOrderId = '',
    required this.status,
    required this.createdAt,
    this.isManualApproval = false,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      courseId: data['courseId'] ?? '',
      courseName: data['courseName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      razorpayPaymentId: data['razorpayPaymentId'] ?? '',
      razorpayOrderId: data['razorpayOrderId'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isManualApproval: data['isManualApproval'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'studentId': studentId,
        'studentName': studentName,
        'courseId': courseId,
        'courseName': courseName,
        'amount': amount,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpayOrderId': razorpayOrderId,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'isManualApproval': isManualApproval,
      };
}
