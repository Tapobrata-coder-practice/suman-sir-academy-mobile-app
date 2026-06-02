// lib/models/course_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum CourseType { monthly, fullCourse, demo, batch }

enum CourseStatus { active, expired, upcoming }

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final double price;
  final double? discountPrice;
  final CourseType type;
  final String? batchId;
  final List<String> folderIds;
  final int totalVideos;
  final int totalPdfs;
  final bool isActive;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final String? bannerImageUrl;
  final List<String> features;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.price,
    this.discountPrice,
    required this.type,
    this.batchId,
    this.folderIds = const [],
    this.totalVideos = 0,
    this.totalPdfs = 0,
    this.isActive = true,
    this.expiryDate,
    required this.createdAt,
    this.bannerImageUrl,
    this.features = const [],
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      discountPrice: (data['discountPrice'])?.toDouble(),
      type: CourseType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CourseType.fullCourse,
      ),
      batchId: data['batchId'],
      folderIds: List<String>.from(data['folderIds'] ?? []),
      totalVideos: data['totalVideos'] ?? 0,
      totalPdfs: data['totalPdfs'] ?? 0,
      isActive: data['isActive'] ?? true,
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bannerImageUrl: data['bannerImageUrl'],
      features: List<String>.from(data['features'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        'price': price,
        'discountPrice': discountPrice,
        'type': type.name,
        'batchId': batchId,
        'folderIds': folderIds,
        'totalVideos': totalVideos,
        'totalPdfs': totalPdfs,
        'isActive': isActive,
        'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'bannerImageUrl': bannerImageUrl,
        'features': features,
      };

  double get effectivePrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  int get discountPercent =>
      hasDiscount ? (((price - discountPrice!) / price) * 100).round() : 0;
}

class VideoModel {
  final String id;
  final String title;
  final String? description;
  final String? youtubeId;
  final String? firebaseUrl;
  final String? thumbnailUrl;
  final int duration; // in seconds
  final String folderId;
  final String courseId;
  final int orderIndex;
  final String? pdfUrl;
  final String? externalLink;
  final bool isDownloadable;
  final DateTime uploadedAt;

  VideoModel({
    required this.id,
    required this.title,
    this.description,
    this.youtubeId,
    this.firebaseUrl,
    this.thumbnailUrl,
    this.duration = 0,
    required this.folderId,
    required this.courseId,
    required this.orderIndex,
    this.pdfUrl,
    this.externalLink,
    this.isDownloadable = false,
    required this.uploadedAt,
  });

  factory VideoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      youtubeId: data['youtubeId'],
      firebaseUrl: data['firebaseUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      duration: data['duration'] ?? 0,
      folderId: data['folderId'] ?? '',
      courseId: data['courseId'] ?? '',
      orderIndex: data['orderIndex'] ?? 0,
      pdfUrl: data['pdfUrl'],
      externalLink: data['externalLink'],
      isDownloadable: data['isDownloadable'] ?? false,
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'youtubeId': youtubeId,
        'firebaseUrl': firebaseUrl,
        'thumbnailUrl': thumbnailUrl,
        'duration': duration,
        'folderId': folderId,
        'courseId': courseId,
        'orderIndex': orderIndex,
        'pdfUrl': pdfUrl,
        'externalLink': externalLink,
        'isDownloadable': isDownloadable,
        'uploadedAt': Timestamp.fromDate(uploadedAt),
      };

  String get durationFormatted {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    if (hours > 0) return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isYouTube => youtubeId != null;
}

class FolderModel {
  final String id;
  final String title;
  final String courseId;
  final int orderIndex;
  final int videoCount;
  final DateTime createdAt;

  FolderModel({
    required this.id,
    required this.title,
    required this.courseId,
    required this.orderIndex,
    this.videoCount = 0,
    required this.createdAt,
  });

  factory FolderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FolderModel(
      id: doc.id,
      title: data['title'] ?? '',
      courseId: data['courseId'] ?? '',
      orderIndex: data['orderIndex'] ?? 0,
      videoCount: data['videoCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'courseId': courseId,
        'orderIndex': orderIndex,
        'videoCount': videoCount,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

class LiveClassModel {
  final String id;
  final String title;
  final String? description;
  final String courseId;
  final String batchId;
  final DateTime scheduledAt;
  final String? meetLink;
  final String? youtubeStreamId;
  final bool isLive;
  final bool hasEnded;
  final String? recordingUrl;

  LiveClassModel({
    required this.id,
    required this.title,
    this.description,
    required this.courseId,
    required this.batchId,
    required this.scheduledAt,
    this.meetLink,
    this.youtubeStreamId,
    this.isLive = false,
    this.hasEnded = false,
    this.recordingUrl,
  });

  factory LiveClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LiveClassModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      courseId: data['courseId'] ?? '',
      batchId: data['batchId'] ?? '',
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      meetLink: data['meetLink'],
      youtubeStreamId: data['youtubeStreamId'],
      isLive: data['isLive'] ?? false,
      hasEnded: data['hasEnded'] ?? false,
      recordingUrl: data['recordingUrl'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'courseId': courseId,
        'batchId': batchId,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'meetLink': meetLink,
        'youtubeStreamId': youtubeStreamId,
        'isLive': isLive,
        'hasEnded': hasEnded,
        'recordingUrl': recordingUrl,
      };
}

class BatchModel {
  final String id;
  final String name;
  final String description;
  final String semester;
  final List<String> courseIds;
  final bool isActive;
  final DateTime createdAt;

  BatchModel({
    required this.id,
    required this.name,
    required this.description,
    required this.semester,
    this.courseIds = const [],
    this.isActive = true,
    required this.createdAt,
  });

  factory BatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BatchModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      semester: data['semester'] ?? '',
      courseIds: List<String>.from(data['courseIds'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'description': description,
        'semester': semester,
        'courseIds': courseIds,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
