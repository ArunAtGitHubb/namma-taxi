import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  /// Replace with your Sentry DSN
  static const String dsn =
      'https://52715299650e56db0fec7265206097bd@o4511021471760384.ingest.de.sentry.io/4511021472219216';

  static Future<void> initialize(FutureOr<void> Function() appRunner) async {
    await SentryFlutter.init((options) {
      options.dsn = dsn;
      options.tracesSampleRate = kDebugMode ? 1.0 : 0.3;
      options.profilesSampleRate = kDebugMode ? 1.0 : 0.1;
      options.attachScreenshot = true;
      options.attachViewHierarchy = true;
      options.enableAutoNativeBreadcrumbs = true;
      options.enableAutoPerformanceTracing = true;
      options.environment = kDebugMode ? 'development' : 'production';
    }, appRunner: appRunner);
  }

  static void captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? message,
  }) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: message != null ? Hint.withMap({'message': message}) : null,
    );
  }

  static void captureMessage(String message, {SentryLevel? level}) {
    Sentry.captureMessage(message, level: level);
  }

  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data ?? {},
        timestamp: DateTime.now(),
      ),
    );
  }

  static Future<void> setUser({
    required String id,
    String? email,
    String? name,
  }) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: id, email: email, username: name));
    });
  }

  static Future<void> clearUser() async {
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  static ISentrySpan startTransaction({
    required String name,
    required String operation,
  }) {
    return Sentry.startTransaction(name, operation);
  }
}

/// Re-export for convenient usage in router
typedef AppNavigatorObserver = SentryNavigatorObserver;
