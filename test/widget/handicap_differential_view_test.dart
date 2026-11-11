import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfer_app/core/di/service_locator.dart';
import 'package:golfer_app/presentation/handicap_differential/handicap_differential_view.dart';
import 'package:golfer_app/presentation/handicap_differential/widgets/differential_cockpit_card.dart';
import 'package:golfer_app/presentation/handicap_differential/widgets/net_double_bogey_table.dart';
import 'package:golfer_app/presentation/handicap_differential/widgets/whs_history_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  group('HandicapDifferentialView Widget Tests', () {
    testWidgets('renders all WHS differential widgets in portrait mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: HandicapDifferentialView()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('USGA Handicap Differential'), findsOneWidget);
      expect(find.byType(DifferentialCockpitCard), findsOneWidget);
      expect(find.byType(NetDoubleBogeyTable), findsOneWidget);
      expect(find.byType(WhsHistoryCard), findsOneWidget);
      expect(find.text('SUBMIT OFFICIAL WHS SCORE'), findsOneWidget);
    });

    testWidgets('renders without overflow in 800x360 landscape viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: HandicapDifferentialView()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DifferentialCockpitCard), findsOneWidget);
      expect(find.byType(NetDoubleBogeyTable), findsOneWidget);
      expect(find.byType(WhsHistoryCard), findsOneWidget);
    });

    testWidgets('tapping submit button displays feedback toast', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: HandicapDifferentialView()),
      );
      await tester.pumpAndSettle();

      final submitBtn = find.text('SUBMIT OFFICIAL WHS SCORE');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
