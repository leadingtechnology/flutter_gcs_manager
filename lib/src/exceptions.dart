
class GcsException implements Exception {
  final String message;
  final Exception? originalException;

  GcsException(this.message, [this.originalException]);

  @override
  String toString() {
    if (originalException != null) {
      return 'GcsException: $message\nOriginal Exception: $originalException';
    } else {
      return 'GcsException: $message';
    }
  }
}
