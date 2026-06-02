// lib/services/course_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/course_model.dart';

class CourseService extends GetxService {
  static CourseService get instance => Get.find<CourseService>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<CourseModel>> getAllCourses() {
    return _db
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(CourseModel.fromFirestore).toList());
  }

  Stream<List<CourseModel>> getStudentCourses(List<String> courseIds) {
    if (courseIds.isEmpty) return Stream.value([]);
    return _db
        .collection('courses')
        .where(FieldPath.documentId, whereIn: courseIds)
        .snapshots()
        .map((snap) => snap.docs.map(CourseModel.fromFirestore).toList());
  }

  Future<List<FolderModel>> getCourseFolders(String courseId) async {
    final snap = await _db
        .collection('folders')
        .where('courseId', isEqualTo: courseId)
        .orderBy('orderIndex')
        .get();
    return snap.docs.map(FolderModel.fromFirestore).toList();
  }

  Future<List<VideoModel>> getFolderVideos(String folderId) async {
    final snap = await _db
        .collection('videos')
        .where('folderId', isEqualTo: folderId)
        .orderBy('orderIndex')
        .get();
    return snap.docs.map(VideoModel.fromFirestore).toList();
  }

  Future<List<LiveClassModel>> getUpcomingLiveClasses(String batchId) async {
    final now = DateTime.now();
    final snap = await _db
        .collection('liveClasses')
        .where('batchId', isEqualTo: batchId)
        .where('hasEnded', isEqualTo: false)
        .where('scheduledAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('scheduledAt')
        .limit(10)
        .get();
    return snap.docs.map(LiveClassModel.fromFirestore).toList();
  }

  Stream<LiveClassModel?> getLiveClass(String batchId) {
    return _db
        .collection('liveClasses')
        .where('batchId', isEqualTo: batchId)
        .where('isLive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty
            ? null
            : LiveClassModel.fromFirestore(snap.docs.first));
  }

  Future<void> updateWatchProgress(
      String userId, String videoId, double progress) async {
    await _db.collection('students').doc(userId).update({
      'watchProgress.$videoId': progress,
    });
  }

  Future<void> addCourse(CourseModel course) async {
    await _db.collection('courses').add(course.toFirestore());
  }

  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    await _db.collection('courses').doc(id).update(data);
  }

  Future<void> deleteCourse(String id) async {
    await _db.collection('courses').doc(id).delete();
  }

  Future<void> addFolder(FolderModel folder) async {
    await _db.collection('folders').add(folder.toFirestore());
  }

  Future<void> addVideo(VideoModel video) async {
    await _db.collection('videos').add(video.toFirestore());
  }

  Future<void> scheduleLiveClass(LiveClassModel liveClass) async {
    await _db.collection('liveClasses').add(liveClass.toFirestore());
  }

  Future<void> markLiveClassActive(String id, bool isLive) async {
    await _db.collection('liveClasses').doc(id).update({'isLive': isLive});
  }
}
