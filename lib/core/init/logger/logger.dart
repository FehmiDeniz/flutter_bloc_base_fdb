import 'package:logger/logger.dart' as log_package;

class Logger {
  static Logger? _instance;
  static Logger get instance {
    _instance ??= Logger._init();
    return _instance!;
  }

  late final log_package.Logger _logger;

  Logger._init() {
    _logger = log_package.Logger(
      printer: log_package.PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: log_package.DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: log_package.Level.debug,
    );
  }

  // Debug level logging
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  // Info level logging
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  // Warning level logging
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  // Error level logging
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // Fatal level logging
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // Map to fatal level in logger package
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Trace level logging (replaces verbose)
  void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // Map to trace level in logger package
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  // Log with custom level
  void log(log_package.Level level, dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.log(level, message, error: error, stackTrace: stackTrace);
  }

  // Log API request
  void logApiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) {
    _logger.i('🌐 API Request', error: {
      'method': method,
      'url': url,
      'headers': headers,
      'queryParameters': queryParameters,
      'body': body,
    });
  }

  // Log API response
  void logApiResponse({
    required int statusCode,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
    int? responseTime,
  }) {
    _logger.i('📡 API Response', error: {
      'statusCode': statusCode,
      'url': url,
      'headers': headers,
      'body': body,
      'responseTime': responseTime != null ? '${responseTime}ms' : null,
    });
  }

  // Log API error
  void logApiError({
    required String method,
    required String url,
    required dynamic error,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    StackTrace? stackTrace,
  }) {
    _logger.e('❌ API Error', error: {
      'method': method,
      'url': url,
      'headers': headers,
      'queryParameters': queryParameters,
      'body': body,
      'error': error,
    }, stackTrace: stackTrace);
  }

  // Log navigation
  void logNavigation({
    required String from,
    required String to,
    Map<String, dynamic>? arguments,
  }) {
    _logger.i('🧭 Navigation', error: {
      'from': from,
      'to': to,
      'arguments': arguments,
    });
  }

  // Log user action
  void logUserAction({
    required String action,
    Map<String, dynamic>? parameters,
  }) {
    _logger.i('👤 User Action', error: {
      'action': action,
      'parameters': parameters,
    });
  }

  // Log performance
  void logPerformance({
    required String operation,
    required int duration,
    Map<String, dynamic>? metadata,
  }) {
    _logger.i('⚡ Performance', error: {
      'operation': operation,
      'duration': '${duration}ms',
      'metadata': metadata,
    });
  }

  // Log database operation
  void logDatabaseOperation({
    required String operation,
    required String table,
    Map<String, dynamic>? data,
    Map<String, dynamic>? where,
  }) {
    _logger.i('🗄️ Database', error: {
      'operation': operation,
      'table': table,
      'data': data,
      'where': where,
    });
  }

  // Log cache operation
  void logCacheOperation({
    required String operation,
    required String key,
    dynamic value,
  }) {
    _logger.i('💾 Cache', error: {
      'operation': operation,
      'key': key,
      'value': value,
    });
  }

  // Log error with context
  void logErrorWithContext({
    required String message,
    required String context,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    _logger.e('🚨 Error in $context', error: {
      'message': message,
      'context': context,
      'error': error,
      'additionalData': additionalData,
    }, stackTrace: stackTrace);
  }

  // Log success with context
  void logSuccessWithContext({
    required String message,
    required String context,
    Map<String, dynamic>? data,
  }) {
    _logger.i('✅ Success in $context', error: {
      'message': message,
      'context': context,
      'data': data,
    });
  }

  // Set log level
  void setLevel(log_package.Level level) {
    log_package.Logger.level = level;
  }

  // Check if logging is enabled for level
  bool isLoggable(log_package.Level level) {
    return log_package.Logger.level.index <= level.index;
  }

  // Close logger
  void close() {
    _logger.close();
  }
}

// Global logger instance
final logger = Logger.instance;
