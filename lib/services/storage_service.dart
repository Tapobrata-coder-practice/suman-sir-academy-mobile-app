// lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  static StorageService get instance => Get.find<StorageService>();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final RxDouble uploadProgress = 0.0.obs;

  Future<String?> uploadFile({
    required File file,
    required String path,
    String? contentType,
  }) async {
    try {
      uploadProgress.value = 0;
      final ref = _storage.ref().child(path);
      final metadata = contentType != null
          ? SettableMetadata(contentType: contentType)
          : null;

      final uploadTask = metadata != null
          ? ref.putFile(file, metadata)
          : ref.putFile(file);

      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        uploadProgress.value = progress;
      });

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      uploadProgress.value = 1.0;
      return url;
    } catch (e) {
      uploadProgress.value = 0;
      return null;
    }
  }

  Future<String?> uploadImage({
    required File imageFile,
    required String folder,
    required String fileName,
  }) async {
    return uploadFile(
      file: imageFile,
      path: '$folder/$fileName.jpg',
      contentType: 'image/jpeg',
    );
  }

  Future<String?> uploadVideo({
    required File videoFile,
    required String courseId,
    required String videoId,
  }) async {
    return uploadFile(
      file: videoFile,
      path: 'videos/$courseId/$videoId.mp4',
      contentType: 'video/mp4',
    );
  }

  Future<String?> uploadPdf({
    required File pdfFile,
    required String courseId,
    required String pdfId,
  }) async {
    return uploadFile(
      file: pdfFile,
      path: 'pdfs/$courseId/$pdfId.pdf',
      contentType: 'application/pdf',
    );
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
