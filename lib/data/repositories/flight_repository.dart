import '../../core/constants/app_constants.dart';
import '../../core/constants/golf_courses.dart';
import '../../core/storage/preferences_service.dart';
import '../models/flight_model.dart';
import '../models/player_model.dart';

class FlightRepository {
  final PreferencesService _prefs;

  FlightRepository(this._prefs);

  static const PlayerModel defaultSeededPlayer = PlayerModel(
    id: 'safeer_hussain',
    name: 'Safeer Hussain',
    handicapIndex: 4.2,
    avatarAsset: 'assets/images/avatar_safeer.png',
    teeBox: AppConstants.teeBlack,
    courseHandicap: 5,
    isCurrentDeviceUser: true,
  );

  static const List<PlayerModel> availableClubMembers = [
    defaultSeededPlayer,
    PlayerModel(
      id: 'm_khan',
      name: 'M. Khan',
      handicapIndex: 8.4,
      avatarAsset: 'assets/images/avatar_player2.png',
      teeBox: AppConstants.teeBlack,
      courseHandicap: 10,
    ),
    PlayerModel(
      id: 'ali_tariq',
      name: 'Ali Tariq',
      handicapIndex: 14.1,
      avatarAsset: 'assets/images/avatar_player3.png',
      teeBox: AppConstants.teeBlue,
      courseHandicap: 16,
    ),
    PlayerModel(
      id: 'zayd_karim',
      name: 'Zayd Karim',
      handicapIndex: 18.0,
      avatarAsset: 'assets/images/avatar_player4.png',
      teeBox: AppConstants.teeWhite,
      courseHandicap: 20,
    ),
  ];

  FlightModel getOrCreateActiveFlight() {
    final existing = _prefs.getActiveFlight();
    if (existing != null) return existing;

    final defaultFlight = FlightModel(
      courseId: GolfCourses.lahoreGarrison.id,
      courseName: GolfCourses.lahoreGarrison.name,
      defaultTeeBox: AppConstants.teeBlack,
      gameFormat: AppConstants.formatStrokePlay,
      players: [defaultSeededPlayer, availableClubMembers[1]],
      startedAt: DateTime.now(),
    );

    _prefs.saveActiveFlight(defaultFlight);
    return defaultFlight;
  }

  Future<void> saveActiveFlight(FlightModel flight) async {
    await _prefs.saveActiveFlight(flight);
  }

  Future<void> clearActiveFlight() async {
    await _prefs.clearActiveFlight();
  }
}
