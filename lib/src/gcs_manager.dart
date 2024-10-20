import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis/storage/v1.dart' as storage;
import 'gcs_service.dart';
import 'exceptions.dart';

class GcsManager {
  final GcsService service;

  GcsManager._({required this.service});

  /// 初始化GcsManager，加载服务账号密钥并创建GcsService
  static Future<GcsManager> initialize({
    required String
        serviceAccountPath, // e.g., 'assets/secrets/ldtech-5a246976a47b.json'
  }) async {
    try {
      // 加载服务账号密钥
      String keyData = await rootBundle.loadString(serviceAccountPath);
      Map<String, dynamic> keyJson = json.decode(keyData);

      // 创建服务账号凭据
      ServiceAccountCredentials credentials =
          ServiceAccountCredentials.fromJson(keyJson);

      // 指定需要的权限
      const List<String> scopes = [
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/devstorage.read_write',
      ];

      // 创建认证客户端
      AutoRefreshingAuthClient authClient =
          await clientViaServiceAccount(credentials, scopes);

      // 创建Storage API实例
      storage.StorageApi storageApi = storage.StorageApi(authClient);

      // 创建GcsService实例
      GcsService gcsService = GcsService(storageApi: storageApi);

      return GcsManager._(service: gcsService);
    } catch (e, stackTrace) {
      // 如果初始化失败，记录错误并抛出自定义异常
      // 假设GcsService内部有一个静态Crashlytics实例
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: '初始化GcsManager失败');
      throw GcsException('初始化GcsManager失败', e as Exception?);
    }
  }
}
