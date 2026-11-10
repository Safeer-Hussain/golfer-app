import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_service.dart';
import '../storage/database_helper.dart';
import '../storage/preferences_service.dart';
import '../theme/theme_controller.dart';
import '../../data/repositories/club_bag_repository.dart';
import '../../data/repositories/clubhouse_repository.dart';
import '../../data/repositories/flight_repository.dart';
import '../../data/repositories/scorecard_repository.dart';
import '../../domain/usecases/caddie_strategy_usecase.dart';
import '../../domain/usecases/calculate_score_usecase.dart';
import '../../domain/usecases/green_reading_usecase.dart';
import '../../domain/usecases/nassau_calculator_usecase.dart';
import '../../presentation/ai_caddie/ai_caddie_controller.dart';
import '../../presentation/clubhouse_analytics/clubhouse_controller.dart';
import '../../presentation/flight_setup/flight_setup_controller.dart';
import '../../presentation/green_reading/green_reading_controller.dart';
import '../../presentation/rangefinder/rangefinder_controller.dart';
import '../../presentation/scorecard/scorecard_controller.dart';
import '../../presentation/settings/settings_controller.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator({SharedPreferences? mockPrefs}) async {
  // Clear any existing registrations in tests
  await sl.reset();

  // Storage & Core
  final prefsInstance = mockPrefs ?? await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefsInstance);
  sl.registerSingleton<PreferencesService>(PreferencesService(sl<SharedPreferences>()));
  sl.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);

  // Network
  sl.registerSingleton<NetworkService>(NetworkService.create(sl<PreferencesService>()));

  // Repositories
  sl.registerSingleton<FlightRepository>(FlightRepository(sl<PreferencesService>()));
  sl.registerSingleton<ScorecardRepository>(
    ScorecardRepository(sl<PreferencesService>(), sl<DatabaseHelper>()),
  );
  sl.registerSingleton<ClubBagRepository>(ClubBagRepository(sl<DatabaseHelper>()));
  sl.registerSingleton<ClubhouseRepository>(ClubhouseRepository(sl<DatabaseHelper>()));

  // Use Cases
  sl.registerSingleton<CalculateScoreUseCase>(CalculateScoreUseCase());
  sl.registerSingleton<CaddieStrategyUseCase>(CaddieStrategyUseCase());
  sl.registerSingleton<NassauCalculatorUseCase>(NassauCalculatorUseCase());
  sl.registerSingleton<GreenReadingUseCase>(GreenReadingUseCase());

  // Controllers
  sl.registerSingleton<ThemeController>(ThemeController(sl<PreferencesService>()));

  final flightSetupController = FlightSetupController(sl<FlightRepository>());
  sl.registerSingleton<FlightSetupController>(flightSetupController);

  final scorecardController = ScorecardController(
    sl<ScorecardRepository>(),
    sl<PreferencesService>(),
    sl<CalculateScoreUseCase>(),
    sl<ClubhouseRepository>(),
  );
  scorecardController.initializeWithFlight(flightSetupController.getCurrentFlightModel());
  sl.registerSingleton<ScorecardController>(scorecardController);

  final rangefinderController = RangefinderController(
    sl<PreferencesService>(),
    sl<ClubBagRepository>(),
  );
  rangefinderController.syncWithHole(
    scorecardController.course,
    scorecardController.currentHoleIndex,
    scorecardController.activeScorecard.teeBox,
  );
  sl.registerSingleton<RangefinderController>(rangefinderController);

  final aiCaddieController = AiCaddieController(
    sl<ClubBagRepository>(),
    sl<CaddieStrategyUseCase>(),
  );
  aiCaddieController.syncHoleContext(
    scorecardController.course,
    scorecardController.currentHoleIndex,
    scorecardController.activeScorecard.teeBox,
  );
  sl.registerSingleton<AiCaddieController>(aiCaddieController);

  sl.registerSingleton<ClubhouseController>(
    ClubhouseController(sl<ClubhouseRepository>(), sl<ClubBagRepository>()),
  );

  sl.registerSingleton<GreenReadingController>(
    GreenReadingController(sl<GreenReadingUseCase>()),
  );

  sl.registerSingleton<SettingsController>(
    SettingsController(sl<PreferencesService>(), sl<NetworkService>()),
  );
}
