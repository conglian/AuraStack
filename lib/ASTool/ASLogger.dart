import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ASLogger {
  ASLogger._internal();

  static final ASLogger _instance = ASLogger._internal();

  factory ASLogger() => _instance;

  static ASLogger get instance => _instance;

  final Logger _logger = Logger(
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 100,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        noBoxingByDefault: true,
        excludeBox: const {Level.error: false, Level.fatal: false},
        levelColors: const {
          Level.debug: AnsiColor.fg(14),
          Level.info: AnsiColor.fg(12),
          Level.warning: AnsiColor.fg(220),
          Level.error: AnsiColor.fg(196),
          Level.fatal: AnsiColor.fg(199),
        },
      ),
    ),
  );

  final Logger _successLogger = Logger(
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        lineLength: 100,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        noBoxingByDefault: true,
        levelColors: const {Level.info: AnsiColor.fg(46)},
      ),
      info: 'SUCCESS',
    ),
  );

  void debug(Object? message, {String? tag}) {
    _logger.d(_withTag(message, tag));
  }

  void debugOnly(Object? message, {String? tag}) {
    if (!kDebugMode) return;
    _logger.d(_withTag(message, tag));
  }

  void info(Object? message, {String? tag}) {
    _logger.i(_withTag(message, tag));
  }

  void success(Object? message, {String? tag}) {
    _successLogger.i(_withTag(message, tag));
  }

  void warning(Object? message, {String? tag}) {
    _logger.w(_withTag(message, tag));
  }

  void error(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(_withTag(message, tag), error: error, stackTrace: stackTrace);
  }

  void fatal(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(_withTag(message, tag), error: error, stackTrace: stackTrace);
  }

  Object? _withTag(Object? message, String? tag) {
    if (tag == null || tag.isEmpty) {
      return message;
    }
    return '[$tag] $message';
  }
}

final ASLogger asLog = ASLogger.instance;
