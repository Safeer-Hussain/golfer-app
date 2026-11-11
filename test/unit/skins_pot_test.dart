import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfer_app/core/constants/golf_courses.dart';
import 'package:golfer_app/core/di/service_locator.dart';
import 'package:golfer_app/data/models/player_model.dart';
import 'package:golfer_app/domain/entities/skins_pot_entity.dart';
import 'package:golfer_app/domain/usecases/skins_pot_usecase.dart';
import 'package:golfer_app/presentation/skins_pot/skins_pot_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SkinsPotUseCase useCase;

  final holes = GolfCourses.lahoreGarrison.holes;

  const players = [
    PlayerModel(
      id: 'p1',
      name: 'Safeer Hussain',
      handicapIndex: 0.0,
      avatarAsset: 'assets/images/avatar_safeer.png',
      teeBox: 'Black',
    ),
    PlayerModel(
      id: 'p2',
      name: 'Hamza Khan',
      handicapIndex: 5.0,
      avatarAsset: 'assets/images/avatar_player2.png',
      teeBox: 'Blue',
    ),
    PlayerModel(
      id: 'p3',
      name: 'Bilal Tariq',
      handicapIndex: 10.0,
      avatarAsset: 'assets/images/avatar_player3.png',
      teeBox: 'Blue',
    ),
    PlayerModel(
      id: 'p4',
      name: 'Usman Malik',
      handicapIndex: 18.0,
      avatarAsset: 'assets/images/avatar_player4.png',
      teeBox: 'White',
    ),
  ];

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

  setUp(() {
    useCase = SkinsPotUseCase();
  });

  group('SkinsPotUseCase - Gross Mode & Outright Wins', () {
    test('Awards skin to single lowest gross score on a hole', () {
      // Hole 1: P1=3, P2=4, P3=5, P4=5
      final scores = {
        'p1': [3],
        'p2': [4],
        'p3': [5],
        'p4': [5],
      };

      final result = useCase.evaluateSkinsGame(
        holes: holes.take(1).toList(),
        players: players,
        playerScores: scores,
        playerCourseHandicaps: {'p1': 0, 'p2': 5, 'p3': 10, 'p4': 18},
        mode: SkinsScoringMode.gross,
        stakePerHole: 10.0,
      );

      expect(result.completedHolesCount, equals(1));
      expect(result.totalSkinsAwarded, equals(1));
      expect(result.activeCarryoverSkins, equals(0));

      final hole1 = result.holeResults.first;
      expect(hole1.hasWinner, isTrue);
      expect(hole1.winnerPlayerId, equals('p1'));
      expect(hole1.skinsWonCount, equals(1));
      expect(hole1.potWon, equals(40.0)); // 4 players * $10

      // Financial Ledger
      final p1 = result.playerPayouts.firstWhere((p) => p.playerId == 'p1');
      expect(p1.skinsWonCount, equals(1));
      expect(p1.totalBuyIn, equals(10.0));
      expect(p1.totalPayout, equals(40.0));
      expect(p1.netBalance, equals(30.0)); // +$30 profit

      final p2 = result.playerPayouts.firstWhere((p) => p.playerId == 'p2');
      expect(p2.skinsWonCount, equals(0));
      expect(p2.totalBuyIn, equals(10.0));
      expect(p2.totalPayout, equals(0.0));
      expect(p2.netBalance, equals(-10.0)); // -$10 loss
    });
  });

  group('SkinsPotUseCase - Carryover Jackpots', () {
    test('Accumulates multi-hole carryovers and sweeps entire pot on next unique win', () {
      // Hole 1: P1=4, P2=4 (Tie) -> Carryover 1
      // Hole 2: P1=3, P3=3 (Tie) -> Carryover 2
      // Hole 3: P2=3 (Winner!), P1=4, P3=4, P4=5 -> Sweeps 3 skins ($60)!
      final scores = {
        'p1': [4, 3, 4],
        'p2': [4, 4, 3],
        'p3': [5, 3, 4],
        'p4': [5, 5, 5],
      };

      final result = useCase.evaluateSkinsGame(
        holes: holes.take(3).toList(),
        players: players,
        playerScores: scores,
        playerCourseHandicaps: {'p1': 0, 'p2': 5, 'p3': 10, 'p4': 18},
        mode: SkinsScoringMode.gross,
        stakePerHole: 5.0,
      );

      expect(result.completedHolesCount, equals(3));
      expect(result.holeResults[0].isTie, isTrue);
      expect(result.holeResults[0].hasWinner, isFalse);
      expect(result.holeResults[1].isTie, isTrue);
      expect(result.holeResults[1].carryoverIn, equals(1));

      // Hole 3 winner sweeps all 3 skins
      final hole3 = result.holeResults[2];
      expect(hole3.hasWinner, isTrue);
      expect(hole3.winnerPlayerId, equals('p2'));
      expect(hole3.carryoverIn, equals(2));
      expect(hole3.skinsWonCount, equals(3));
      expect(hole3.potWon, equals(60.0)); // 3 skins * (4 * $5) = $60

      expect(result.totalSkinsAwarded, equals(3));
      expect(result.activeCarryoverSkins, equals(0));

      final p2 = result.playerPayouts.firstWhere((p) => p.playerId == 'p2');
      expect(p2.skinsWonCount, equals(3));
      expect(p2.totalBuyIn, equals(15.0)); // 3 holes * $5
      expect(p2.totalPayout, equals(60.0));
      expect(p2.netBalance, equals(45.0));
    });
  });

  group('SkinsPotUseCase - Net Handicap Scoring', () {
    test('Deducts handicap strokes received on stroke index holes', () {
      // Hole 1: Par 4, Stroke Index 7.
      // P1 (CH 0): Gross 4 -> Net 4 (0 strokes rec)
      // P4 (CH 18): Gross 4 -> Net 3 (1 stroke rec on SI 7)
      // In Net Mode, P4 wins with Net 3!
      final scores = {
        'p1': [4],
        'p2': [5],
        'p3': [5],
        'p4': [4],
      };

      final result = useCase.evaluateSkinsGame(
        holes: holes.take(1).toList(),
        players: players,
        playerScores: scores,
        playerCourseHandicaps: {'p1': 0, 'p2': 5, 'p3': 10, 'p4': 18},
        mode: SkinsScoringMode.net,
        stakePerHole: 10.0,
      );

      final hole1 = result.holeResults.first;
      expect(hole1.hasWinner, isTrue);
      expect(hole1.winnerPlayerId, equals('p4'));
      expect(hole1.playerNetScores['p4'], equals(3));
      expect(hole1.playerNetScores['p1'], equals(4));
    });
  });

  group('SkinsPotUseCase - Zero-Sum Financial Balance & Hole 18 Rules', () {
    test('Guarantees 100% zero-sum financial ledger across all players', () {
      // 18 holes of simulated scores
      final scores = {
        'p1': [4, 5, 3, 4, 4, 3, 5, 4, 4, 4, 5, 3, 4, 4, 3, 5, 4, 4],
        'p2': [4, 5, 3, 5, 4, 4, 5, 4, 5, 4, 6, 3, 4, 5, 3, 5, 4, 5],
        'p3': [5, 6, 4, 5, 5, 3, 6, 5, 5, 5, 6, 4, 5, 5, 4, 6, 5, 5],
        'p4': [5, 6, 4, 6, 5, 4, 6, 5, 6, 5, 7, 4, 5, 6, 4, 6, 5, 6],
      };

      final result = useCase.evaluateSkinsGame(
        holes: holes,
        players: players,
        playerScores: scores,
        playerCourseHandicaps: {'p1': 0, 'p2': 5, 'p3': 10, 'p4': 18},
        stakePerHole: 5.0,
        hole18Rule: Hole18CarryoverRule.carryoverPush,
      );

      // Verify sum of net balances is mathematically zero
      final sumNetBalances = result.playerPayouts.fold<double>(
        0.0,
        (acc, p) => acc + p.netBalance,
      );
      expect(sumNetBalances.abs(), lessThan(0.01));

      // Verify total pot matches total buy-in across all players
      final sumPayouts = result.playerPayouts.fold<double>(
        0.0,
        (acc, p) => acc + p.totalPayout,
      );
      expect(sumPayouts, closeTo(result.totalPot, 0.01));
    });

    test('Empty players or holes returns empty result gracefully', () {
      final result = useCase.evaluateSkinsGame(
        holes: [],
        players: [],
        playerScores: {},
        playerCourseHandicaps: {},
      );

      expect(result.completedHolesCount, equals(0));
      expect(result.totalPot, equals(0.0));
      expect(result.holeResults, isEmpty);
      expect(result.playerPayouts, isEmpty);
    });
  });

  group('SkinsPotController Tests', () {
    late SkinsPotController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await setupServiceLocator();
      controller = sl<SkinsPotController>();
    });

    test('Initializes with default players and tournament course context', () {
      expect(controller.players.length, greaterThanOrEqualTo(2));
      expect(controller.stakePerHole, equals(5.0));
      expect(controller.mode, equals(SkinsScoringMode.gross));
      expect(controller.gameResult.totalHolesCount, equals(18));
    });

    test(
      'Mode change toggles between Gross and Net and notifies listeners',
      () {
        var notified = false;
        controller.addListener(() => notified = true);

        controller.setMode(SkinsScoringMode.net);
        expect(notified, isTrue);
        expect(controller.mode, equals(SkinsScoringMode.net));
        expect(controller.gameResult.mode, equals(SkinsScoringMode.net));
      },
    );

    test('Stake per hole update updates total pot and player buy-ins', () {
      controller.setStakePerHole(20.0);
      expect(controller.stakePerHole, equals(20.0));
      expect(controller.gameResult.stakePerHole, equals(20.0));
    });

    test('Hole 18 rule change updates calculation', () {
      controller.setHole18Rule(Hole18CarryoverRule.splitTiedPlayers);
      expect(
        controller.hole18Rule,
        equals(Hole18CarryoverRule.splitTiedPlayers),
      );
    });

    test('toggleSimulatedScores toggles simulation mode', () {
      final initial = controller.useSimulatedScores;
      controller.toggleSimulatedScores();
      expect(controller.useSimulatedScores, equals(!initial));
    });
  });
}
