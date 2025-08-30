import 'package:logger/logger.dart';

class LoggerManager {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void debug(String message) {
    _logger.d(message); // Önceki: logger.d(message)
  }

  static void error(String message) {
    _logger.e(message); // Önceki: logger.e(message)
  }

  static void info(String message) {
    _logger.i(message); // Önceki: logger.i(message)
  }

  static void warning(String message) {
    _logger.w(message); // Önceki: logger.w(message)
  }
}
