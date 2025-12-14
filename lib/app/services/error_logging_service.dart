import 'package:logger/logger.dart';
import 'package:get/get.dart';

/// Comprehensive error logging and reporting service
/// Tracks errors, warnings, and info messages for debugging and monitoring
class ErrorLoggingService extends GetxService {
  final _logger = Logger();

  // Observable lists for error tracking
  final errorLog = <ErrorLogEntry>[].obs;
  final warningLog = <ErrorLogEntry>[].obs;

  static const int maxLogEntries = 1000;

  @override
  void onInit() {
    super.onInit();
    _logger.i('ErrorLoggingService initialized');
  }

  /// Log an error with full context
  void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  }) {
    final entry = ErrorLogEntry(
      timestamp: DateTime.now(),
      message: message,
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      context: context,
      severity: ErrorSeverity.error,
    );

    errorLog.add(entry);
    if (errorLog.length > maxLogEntries) {
      errorLog.removeAt(0);
    }

    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a warning
  void logWarning(
    String message, {
    String? context,
  }) {
    final entry = ErrorLogEntry(
      timestamp: DateTime.now(),
      message: message,
      context: context,
      severity: ErrorSeverity.warning,
    );

    warningLog.add(entry);
    if (warningLog.length > maxLogEntries) {
      warningLog.removeAt(0);
    }

    _logger.w(message);
  }

  /// Log info message
  void logInfo(String message, {String? context}) {
    _logger.i('$context: $message');
  }

  /// Get all errors with filters
  List<ErrorLogEntry> getErrorsForContext(String context) {
    return errorLog
        .where((entry) => entry.context?.contains(context) ?? false)
        .toList();
  }

  /// Get recent errors (last N)
  List<ErrorLogEntry> getRecentErrors([int limit = 10]) {
    return errorLog.length > limit
        ? errorLog.sublist(errorLog.length - limit)
        : errorLog;
  }

  /// Clear all logs
  void clearLogs() {
    errorLog.clear();
    warningLog.clear();
  }

  /// Export logs as formatted string
  String exportLogs() {
    final buffer = StringBuffer();
    buffer.writeln('=== ERROR LOG ===');
    for (var entry in errorLog) {
      buffer.writeln('${entry.timestamp}: ${entry.message}');
      if (entry.stackTrace != null) {
        buffer.writeln('${entry.stackTrace}');
      }
      buffer.writeln('---');
    }
    return buffer.toString();
  }
}

/// Error log entry structure
class ErrorLogEntry {
  final DateTime timestamp;
  final String message;
  final String? error;
  final String? stackTrace;
  final String? context;
  final ErrorSeverity severity;

  ErrorLogEntry({
    required this.timestamp,
    required this.message,
    this.error,
    this.stackTrace,
    this.context,
    required this.severity,
  });
}

enum ErrorSeverity { error, warning, info }


