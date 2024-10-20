import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:googleapis/storage/v1.dart' as storage;
import 'exceptions.dart';

class GcsService {
  final storage.StorageApi _storageApi;
  final FirebaseCrashlytics _crashlytics;
  final FirebaseAnalytics _analytics;

  GcsService({
    required storage.StorageApi storageApi,
    Dio? dio,
    FirebaseCrashlytics? crashlytics,
    FirebaseAnalytics? analytics,
  })  : _storageApi = storageApi,
        _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  /// 上传文件（支持CSV、图片、JSON、视频）
  Future<void> uploadFile({
    required String bucketName,
    required String objectName,
    required File file,
    Function(int, int)? onSendProgress,
  }) async {
    try {
      _crashlytics.log('开始上传文件: $objectName 至存储桶: $bucketName');
      _analytics.logEvent(
        name: 'upload_file',
        parameters: {'bucket_name': bucketName, 'object_name': objectName},
      );

      int fileLength = await file.length();
      var stream = file.openRead();

      var media = storage.Media(stream, fileLength);

      await _storageApi.objects.insert(
        storage.Object()..name = objectName,
        bucketName,
        uploadMedia: media,
      );

      _crashlytics.log('文件上传成功: $objectName');
    } catch (e, stackTrace) {
      _crashlytics.recordError(e, stackTrace, reason: '上传文件失败: $objectName');
      throw GcsException('上传文件失败: $objectName', e as Exception?);
    }
  }

  /// 下载文件（支持CSV、图片、JSON、视频）
  Future<void> downloadFile({
    required String bucketName,
    required String objectName,
    required String savePath,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      _crashlytics.log('开始下载文件: $objectName 从存储桶: $bucketName');
      _analytics.logEvent(
        name: 'download_file',
        parameters: {'bucket_name': bucketName, 'object_name': objectName},
      );

      final media = await _storageApi.objects.get(
        bucketName,
        objectName,
        downloadOptions: storage.DownloadOptions.fullMedia,
      ) as storage.Media;

      final file = File(savePath);
      IOSink sink = file.openWrite();

      int received = 0;
      media.stream.listen(
        (data) {
          sink.add(data);
          received += data.length;
          if (onReceiveProgress != null && media.length != null) {
            onReceiveProgress(received, media.length!);
          }
        },
        onDone: () async {
          await sink.close();
          _crashlytics.log('文件下载完成: $objectName');
        },
        onError: (e, stackTrace) {
          _crashlytics.recordError(e, stackTrace,
              reason: '下载文件失败: $objectName');
          throw GcsException('下载文件失败: $objectName', e as Exception?);
        },
        cancelOnError: true,
      );
    } catch (e, stackTrace) {
      _crashlytics.recordError(e, stackTrace, reason: '下载文件失败: $objectName');
      throw GcsException('下载文件失败: $objectName', e as Exception?);
    }
  }

  /// 删除文件
  Future<void> deleteFile({
    required String bucketName,
    required String objectName,
  }) async {
    try {
      _crashlytics.log('开始删除文件: $objectName 从存储桶: $bucketName');
      _analytics.logEvent(
        name: 'delete_file',
        parameters: {'bucket_name': bucketName, 'object_name': objectName},
      );

      await _storageApi.objects.delete(bucketName, objectName);

      _crashlytics.log('文件删除成功: $objectName');
    } catch (e, stackTrace) {
      _crashlytics.recordError(e, stackTrace, reason: '删除文件失败: $objectName');
      throw GcsException('删除文件失败: $objectName', e as Exception?);
    }
  }

  /// 列出存储桶中的文件
  Future<List<storage.Object>> listFiles({
    required String bucketName,
    String? prefix,
  }) async {
    try {
      _crashlytics.log('开始列出存储桶: $bucketName 的文件');
      _analytics.logEvent(
        name: 'list_files',
        parameters: {'bucket_name': bucketName, 'prefix': prefix ?? ''},
      );

      final objects =
          await _storageApi.objects.list(bucketName, prefix: prefix);
      _crashlytics
          .log('存储桶: $bucketName 中找到 ${objects.items?.length ?? 0} 个文件');
      return objects.items ?? [];
    } catch (e, stackTrace) {
      _crashlytics.recordError(e, stackTrace, reason: '列出文件失败: $bucketName');
      throw GcsException('列出文件失败: $bucketName', e as Exception?);
    }
  }
}
