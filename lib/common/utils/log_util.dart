import 'package:logger/logger.dart';

class Log {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  // Level Debug
  static void d(dynamic message) {
    _logger.d(message);
  }

  // Level Error
  static void e(dynamic message) {
    _logger.e(message);
  }

  // Level Info
  static void i(dynamic message) {
    _logger.i(message);
  }

  // Level Warning
  static void w(dynamic message) {
    _logger.w(message);
  }

  // Level Trace
  static void t(dynamic message) {
    _logger.t(message);
  }

  // Level Fatal
  static void f(dynamic message) {
    _logger.f(message);
  }
}
