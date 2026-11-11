import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfer_app/core/di/service_locator.dart';
import 'package:golfer_app/presentation/skins_pot/skins_pot_view.dart';
import 'package:golfer_app/presentation/skins_pot/widgets/skins_hole_matrix.dart';
import 'package:golfer_app/presentation/skins_pot/widgets/skins_payout_ledger_card.dart';
import 'package:golfer_app/presentation/skins_pot/widgets/skins_rules_modal.dart';
import 'package:golfer_app/presentation/skins_pot/widgets/skins_summary_cockpit_card.dart';
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

  group('SkinsPotView Widget Tests', () {
    testWidgets('renders all tournament skins widgets in portrait mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: SkinsPotView()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Tournament Skins Pot'), findsWidgets);
      expect(find.byType(SkinsSummaryCockpitCard), findsOneWidget);
      expect(find.byType(SkinsPayoutLedgerCard), findsOneWidget);
      expect(find.byType(SkinsHoleMatrix), findsOneWidget);
      expect(find.text('SHARE PAYOUTS'), findsOneWidget);
    });

    testWidgets('renders without overflow in 800x360 landscape viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: SkinsPotView()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SkinsSummaryCockpitCard), findsOneWidget);
      expect(find.byType(SkinsPayoutLedgerCard), findsOneWidget);
      expect(find.byType(SkinsHoleMatrix), findsOneWidget);
    });

    testWidgets('tapping Gross and Net mode buttons toggles state cleanly', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: SkinsPotView()));
      await tester.pumpAndSettle();

      final netButton = find.text('Net (Handicap)');
      expect(netButton, findsOneWidget);
      await tester.tap(netButton);
      await tester.pumpAndSettle();

      expect(find.text('Net Lowest'), findsOneWidget);

      final grossButton = find.text('Gross');
      expect(grossButton, findsOneWidget);
      await tester.tap(grossButton);
      await tester.pumpAndSettle();

      expect(find.text('Gross Lowest'), findsOneWidget);
    });

    testWidgets('tapping rules icon opens rules modal sheet', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: SkinsPotView()));
      await tester.pumpAndSettle();

      final helpBtn = find.byIcon(Icons.help_outline_rounded);
      expect(helpBtn, findsOneWidget);
      await tester.tap(helpBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SkinsRulesModal), findsOneWidget);
      expect(find.text('Tournament Skins Rules & Regulations'), findsOneWidget);

      final gotItBtn = find.text('GOT IT');
      await tester.tap(gotItBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SkinsRulesModal), findsNothing);
    });

    testWidgets('tapping share button displays feedback toast', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: SkinsPotView()));
      await tester.pumpAndSettle();

      final shareBtn = find.text('SHARE PAYOUTS');
      expect(shareBtn, findsOneWidget);
      await tester.tap(shareBtn);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
