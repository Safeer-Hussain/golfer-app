import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'presentation/splash/splash_view.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await setupServiceLocator();
    } catch (e, stackTrace) {
      debugPrint('Initialization error caught defensively: $e\n$stackTrace');
    }

    runApp(const GolferApp());
  }, (Object error, StackTrace stack) {
    debugPrint('Uncaught asynchronous zone error: $error\n$stack');
  });
}

class GolferApp extends StatelessWidget {
  const GolferApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = sl<ThemeController>();

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          themeMode: themeController.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashView(),
        );
      },
    );
  }
}
