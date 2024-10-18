import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_gcs_manager/src/gcs_service.dart';

class GcsManager {
  final GcsService service;

  GcsManager({required this.service});

  static Future<GcsManager> create(Map<String, dynamic> keyJson) async {
    var client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(keyJson), [
      'https://www.googleapis.com/auth/cloud-platform',
      'https://www.googleapis.com/auth/devstorage.read_write',
    ]);
    var gcsService = GcsService(client);
    return GcsManager(service: gcsService);
  }
}
