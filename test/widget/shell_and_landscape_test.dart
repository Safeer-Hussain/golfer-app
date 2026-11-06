import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:golfer_app/core/di/service_locator.dart';
import 'package:golfer_app/core/theme/theme_controller.dart';
import 'package:golfer_app/presentation/flight_setup/flight_setup_view.dart';
import 'package:golfer_app/presentation/shell/adaptive_scaffold.dart';
import 'package:golfer_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock connectivity channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return ['wifi'];
        }
        return null;
      },
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
  });

  group('Widget & Viewport Tests', () {
    testWidgets('AdaptiveScaffold renders directly with zero duplicate hero tag exceptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveScaffold(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AdaptiveScaffold), findsOneWidget);
    });

    testWidgets('800x360 landscape viewport renders with zero RenderFlex overflows', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: FlightSetupView(onStartRound: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('ThemeController switches between dark and light themes dynamically', (tester) async {
      final themeController = sl<ThemeController>();
      expect(themeController.isDarkMode, isTrue);

      await themeController.toggleTheme();
      expect(themeController.isDarkMode, isFalse);

      await themeController.toggleTheme();
      expect(themeController.isDarkMode, isTrue);
    });

    testWidgets('GolferApp transitions from SplashView to AdaptiveScaffold', (tester) async {
      await tester.pumpWidget(const GolferApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1700));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveScaffold), findsOneWidget);
    });
  });
}
