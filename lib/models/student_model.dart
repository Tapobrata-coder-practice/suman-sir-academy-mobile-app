// lib/models/student_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String uid;
  final String name;
  final String phone;
  final List<String> purchasedCourses;
  final List<String> batchIds;
  final bool isBlocked;
  final bool canSubmitDoubt;
  final String? profileImageUrl;
  final DateTime createdAt;
  final Map<String, dynamic> watchProgress;
  final Map<String, dynamic> attendance;

  StudentModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.purchasedCourses = const [],
    this.batchIds = const [],
    this.isBlocked = false,
    this.canSubmitDoubt = true,
    this.profileImageUrl,
    required this.createdAt,
    this.watchProgress = const {},
    this.attendance = const {},
  });

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      purchasedCourses: List<String>.from(data['purchasedCourses'] ?? []),
      batchIds: List<String>.from(data['batchIds'] ?? []),
      isBlocked: data['isBlocked'] ?? false,
      canSubmitDoubt: data['canSubmitDoubt'] ?? true,
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      watchProgress: Map<String, dynamic>.from(data['watchProgress'] ?? {}),
      attendance: Map<String, dynamic>.from(data['attendance'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'phone': phone,
        'purchasedCourses': purchasedCourses,
        'batchIds': batchIds,
        'isBlocked': isBlocked,
        'canSubmitDoubt': canSubmitDoubt,
        'profileImageUrl': profileImageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'watchProgress': watchProgress,
        'attendance': attendance,
      };

  StudentModel copyWith({
    String? name,
    String? phone,
    List<String>? purchasedCourses,
    List<String>? batchIds,
    bool? isBlocked,
    bool? canSubmitDoubt,
    String? profileImageUrl,
    Map<String, dynamic>? watchProgress,
    Map<String, dynamic>? attendance,
  }) {
    return StudentModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      purchasedCourses: purchasedCourses ?? this.purchasedCourses,
      batchIds: batchIds ?? this.batchIds,
      isBlocked: isBlocked ?? this.isBlocked,
      canSubmitDoubt: canSubmitDoubt ?? this.canSubmitDoubt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      watchProgress: watchProgress ?? this.watchProgress,
      attendance: attendance ?? this.attendance,
    );
  }
}
