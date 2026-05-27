import 'dart:developer';

Future<void> logErrorToFirestore(dynamic error, [StackTrace? stack]) async {
  log(
    'error: ${error?.toString()}',
    name: 'error_logger',
    stackTrace: stack,
  );
}

Future<void> logHttpError(int statusCode, String message) async {
  await logErrorToFirestore('HTTP $statusCode: $message');
}
