import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:golfer_app/core/di/service_locator.dart';
import 'package:golfer_app/presentation/swing_tempo/swing_tempo_view.dart';
import 'package:golfer_app/presentation/swing_tempo/widgets/tempo_arc_gauge.dart';
import 'package:golfer_app/presentation/swing_tempo/widgets/tempo_calibrator_card.dart';
import 'package:golfer_app/presentation/swing_tempo/widgets/tempo_preset_selector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
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

  group('SwingTempoView Widget Tests', () {
    testWidgets('renders all tempo trainer widgets in portrait mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: SwingTempoView()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(TempoArcGauge), findsOneWidget);
      expect(find.byType(TempoPresetSelector), findsOneWidget);
      expect(find.byType(TempoCalibratorCard), findsOneWidget);
      expect(find.text('Swing Tempo Metronome'), findsOneWidget);
    });

    testWidgets('renders without overflow in 800x360 landscape viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: SwingTempoView()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(TempoArcGauge), findsOneWidget);
      expect(find.byType(TempoPresetSelector), findsOneWidget);
    });
  });
}
