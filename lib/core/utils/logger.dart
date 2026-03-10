import 'package:logger/logger.dart' as pkg;

final logger = pkg.Logger(
  printer: pkg.PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: pkg.DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

final loggerNoStack = pkg.Logger(
  printer: pkg.PrettyPrinter(methodCount: 0),
);
