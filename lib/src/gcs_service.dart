import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_gcs_manager/src/exceptions.dart';
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:path_provider/path_provider.dart';

class GcsService {
  final storage.StorageApi _storageApi;
  final Dio _dio;
  final FirebaseCrashlytics _crashlytics;
  final FirebaseAnalytics _analytics;

  GcsService({
    required storage.StorageApi storageApi,
    Dio? dio,
    FirebaseCrashlytics? crashlytics,
    FirebaseAnalytics? analytics,
  })  : _storageApi = storageApi,
        _dio = dio ?? Dio(),
        _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  /// 下载大文件
  Future<void> downloadLargeFile(
    String url,
    String savePath, {
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
      // 记录下载事件
      await _analytics.logEvent(
        name: 'download_file',
        parameters: {'file_url': url},
      );
    } catch (e, stackTrace) {
      await _crashlytics.recordError(e, stackTrace);
      throw GcsException('下载文件失败', e as Exception?);
    }
  }

  /// 上传大文件
  Future<void> uploadLargeFile(
    String bucketName,
    String objectName,
    String filePath, {
    Function(int, int)? onSendProgress,
  }) async {
    try {
      File file = File(filePath);
      int fileLength = await file.length();

      var stream = file.openRead();

      var media = storage.Media(stream, fileLength);

      await _storageApi.objects.insert(
        storage.Object()..name = objectName,
        bucketName,
        uploadMedia: media,
      );
      // 记录上传事件
      await _analytics.logEvent(
        name: 'upload_file',
        parameters: {'bucket_name': bucketName, 'object_name': objectName},
      );
    } catch (e, stackTrace) {
      await _crashlytics.recordError(e, stackTrace);
      throw GcsException('上传文件失败', e as Exception?);
    }
  }

  /// 删除文件
  Future<void> deleteObject(String bucketName, String objectName) async {
    try {
      await _storageApi.objects.delete(bucketName, objectName);
      // 记录删除事件
      await _analytics.logEvent(
        name: 'delete_file',
        parameters: {'bucket_name': bucketName, 'object_name': objectName},
      );
    } catch (e, stackTrace) {
      await _crashlytics.recordError(e, stackTrace);
      throw GcsException('删除文件失败', e as Exception?);
    }
  }

  /// 列出文件
  Future<List<storage.Object>> listObjects(
    String bucketName, {
    String? prefix,
  }) async {
    try {
      final objects =
          await _storageApi.objects.list(bucketName, prefix: prefix);
      return objects.items ?? [];
    } catch (e, stackTrace) {
      await _crashlytics.recordError(e, stackTrace);
      throw GcsException('列出文件失败', e as Exception?);
    }
  }

  /// 获取本地文件路径
  Future<String> getLocalFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }
}
