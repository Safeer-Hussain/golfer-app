import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:golfer_app/core/constants/app_constants.dart';
import 'package:golfer_app/core/constants/golf_courses.dart';
import 'package:golfer_app/core/storage/database_helper.dart';
import 'package:golfer_app/core/storage/preferences_service.dart';
import 'package:golfer_app/data/models/flight_model.dart';
import 'package:golfer_app/data/models/player_model.dart';
import 'package:golfer_app/data/repositories/club_bag_repository.dart';
import 'package:golfer_app/data/repositories/clubhouse_repository.dart';
import 'package:golfer_app/data/repositories/flight_repository.dart';
import 'package:golfer_app/data/repositories/scorecard_repository.dart';
import 'package:golfer_app/domain/usecases/caddie_strategy_usecase.dart';
import 'package:golfer_app/domain/usecases/calculate_score_usecase.dart';
import 'package:golfer_app/presentation/ai_caddie/ai_caddie_controller.dart';
import 'package:golfer_app/presentation/flight_setup/flight_setup_controller.dart';
import 'package:golfer_app/presentation/scorecard/scorecard_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late SharedPreferences prefs;
  late PreferencesService prefsService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    prefsService = PreferencesService(prefs);
  });

  group('FlightSetupController Tests', () {
    test('initializes with default seeded player Safeer Hussain and allows roster expansion', () {
      final flightRepo = FlightRepository(prefsService);
      final controller = FlightSetupController(flightRepo);

      expect(controller.flightPlayers.isNotEmpty, isTrue);
      expect(controller.flightPlayers.first.name, 'Safeer Hussain');
      expect(controller.flightPlayers.first.handicapIndex, 4.2);

      // Add a custom player
      final added = controller.addCustomPlayer(
        name: 'Tariq Malik',
        handicap: 12.0,
        teeBox: AppConstants.teeBlack,
      );
      expect(added, isTrue);
      expect(controller.flightPlayers.length, 3);

      // Verify course handicap calculation
      final lastPlayer = controller.flightPlayers.last;
      expect(lastPlayer.name, 'Tariq Malik');
      expect(lastPlayer.courseHandicap, greaterThan(10));
    });

    test('enforces max 4 players limit in flight', () {
      final flightRepo = FlightRepository(prefsService);
      final controller = FlightSetupController(flightRepo);

      controller.addCustomPlayer(name: 'Player 3', handicap: 10, teeBox: AppConstants.teeBlack);
      controller.addCustomPlayer(name: 'Player 4', handicap: 15, teeBox: AppConstants.teeBlack);
      expect(controller.flightPlayers.length, 4);
      expect(controller.canAddMorePlayers, isFalse);

      final excess = controller.addCustomPlayer(name: 'Player 5', handicap: 20, teeBox: AppConstants.teeBlack);
      expect(excess, isFalse);
      expect(controller.flightPlayers.length, 4);
    });
  });

  group('ScorecardController Tests', () {
    test('updates strokes, putts, and computes net scores across players', () {
      final flight = FlightModel(
        courseId: GolfCourses.lahoreGarrison.id,
        courseName: GolfCourses.lahoreGarrison.name,
        defaultTeeBox: AppConstants.teeBlack,
        gameFormat: AppConstants.formatStrokePlay,
        players: [
          const PlayerModel(id: 'p1', name: 'Safeer', handicapIndex: 4.2, avatarAsset: 'assets/images/avatar_safeer.png', teeBox: AppConstants.teeBlack, courseHandicap: 5, isCurrentDeviceUser: true),
          const PlayerModel(id: 'p2', name: 'MK', handicapIndex: 10.0, avatarAsset: 'assets/images/avatar_player2.png', teeBox: AppConstants.teeBlack, courseHandicap: 10),
        ],
        startedAt: DateTime.now(),
      );

      final scorecardRepo = ScorecardRepository(prefsService, DatabaseHelper.instance);
      final calcUseCase = CalculateScoreUseCase();
      final clubhouseRepo = ClubhouseRepository(DatabaseHelper.instance);

      final controller = ScorecardController(scorecardRepo, prefsService, calcUseCase, clubhouseRepo);
      controller.initializeWithFlight(flight);

      // Hole 1: Par 4
      final initialScoreP1 = controller.getScoreForPlayer('p1', 1);
      expect(initialScoreP1.strokes, 4);

      // Increment strokes to 5 (Bogey)
      controller.updateStrokes('p1', 1, 1);
      final updatedScoreP1 = controller.getScoreForPlayer('p1', 1);
      expect(updatedScoreP1.strokes, 5);

      // Update putts
      controller.updatePutts('p1', 1, 1);
      expect(controller.getScoreForPlayer('p1', 1).putts, 3);

      // Verify Leaderboard calculation
      final leaderboard = controller.getLeaderboard();
      expect(leaderboard.length, 2);
    });

    test('supports hole navigation within bounds (0 to 17)', () {
      final flightRepo = FlightRepository(prefsService);
      final scorecardRepo = ScorecardRepository(prefsService, DatabaseHelper.instance);
      final controller = ScorecardController(scorecardRepo, prefsService, CalculateScoreUseCase(), ClubhouseRepository(DatabaseHelper.instance));
      controller.initializeWithFlight(flightRepo.getOrCreateActiveFlight());

      expect(controller.currentHoleIndex, 0);
      controller.nextHole();
      expect(controller.currentHoleIndex, 1);
      controller.previousHole();
      expect(controller.currentHoleIndex, 0);

      // Boundary test
      controller.previousHole();
      expect(controller.currentHoleIndex, 0);
    });
  });

  group('AiCaddieController Tests', () {
    test('streaming generator runs in try-finally and guarantees isStreaming = false', () async {
      final caddie = AiCaddieController(
        ClubBagRepository(DatabaseHelper.instance),
        CaddieStrategyUseCase(),
      );

      expect(caddie.isStreaming, isFalse);
      final future = caddie.sendUserPrompt('Recommend Club for Current Hole');
      expect(caddie.isStreaming, isTrue);

      await future;
      expect(caddie.isStreaming, isFalse);
      expect(caddie.messages.length, greaterThan(1));
    });
  });
}
