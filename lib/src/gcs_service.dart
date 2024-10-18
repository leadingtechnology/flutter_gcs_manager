import 'package:googleapis/storage/v1.dart' as storage;
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class GcsService {
  final AutoRefreshingAuthClient client;

  GcsService(this.client);

  Future<storage.Object> uploadFile(
      String bucket, String objectName, List<int> bytes) async {
    try {
      var media = storage.Media(Stream.value(bytes), bytes.length);
      var result = await storage.StorageApi(client).objects.insert(
            storage.Object()..name = objectName,
            bucket,
            uploadMedia: media,
          );
      FirebaseCrashlytics.instance
          .log("File uploaded successfully: $objectName");
      return result;
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      FirebaseCrashlytics.instance.log("Failed to upload file: $objectName");
      throw e;
    }
  }

  Future<void> downloadFile(
      String bucket, String objectName, String downloadPath) async {
    try {
      // Implement downloading logic here
      FirebaseCrashlytics.instance
          .log("File downloaded successfully: $objectName");
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      FirebaseCrashlytics.instance.log("Failed to download file: $objectName");
      throw e;
    }
  }

  // More methods can be implemented as needed
}
