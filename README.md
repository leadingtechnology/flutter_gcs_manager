# Google Cloud Storage Integration for Flutter Apps

flutter_gcs_manager is a Flutter package that provides seamless interaction with Google Cloud Storage (GCS), offering the following features:

·Authentication: Uses Google Sign-In for OAuth 2.0 authentication to obtain credentials for accessing GCS.

·File Operations:

  ·Upload Files: Supports background uploads of large files and videos with progress tracking and error handling.
  ·Download Files: Enables background downloads of large files and videos with support for resume capability, progress tracking, and error handling.
  ·Delete Files: Allows the deletion of specific files from GCS.
  ·List Files: Lists files in a specified GCS bucket and path.

·Error Handling: Provides custom exception classes and integrates with Firebase Crashlytics to log error reports.

·Background Task Management: Utilizes the Dio library for streaming to ensure stability when handling large files.

·Logging: Integrated with Firebase Analytics to track user file operations.
