import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/golf_courses.dart';
import '../../core/storage/preferences_service.dart';
import '../../data/models/club_model.dart';
import '../../data/repositories/club_bag_repository.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/hole_entity.dart';

class RangefinderController extends ChangeNotifier {
  final PreferencesService _prefs;
  final ClubBagRepository _clubBagRepository;

  late CourseEntity _course;
  late String _teeBox;
  int _currentHoleIndex = 0;
  LatLng? _targetLocation;
  final Distance _distance = const Distance();

  // Shot tracker state
  bool _isTrackingShot = false;
  LatLng? _shotStartPoint;
  int _lastRecordedShotDistance = 0;
  List<ClubModel> _availableClubs = [];

  RangefinderController(this._prefs, this._clubBagRepository) {
    _course = GolfCourses.lahoreGarrison;
    _teeBox = 'Championship Black';
    _loadClubs();
  }

  CourseEntity get course => _course;
  String get teeBox => _teeBox;
  int get currentHoleIndex => _currentHoleIndex;
  HoleEntity get currentHole => _course.holes[_currentHoleIndex];
  LatLng get targetLocation => _targetLocation ?? currentHole.targetLocation;
  bool get isTrackingShot => _isTrackingShot;
  int get lastRecordedShotDistance => _lastRecordedShotDistance;
  List<ClubModel> get availableClubs => _availableClubs;
  String get unitSystem => _prefs.getUnitSystem();

  Future<void> _loadClubs() async {
    _availableClubs = await _clubBagRepository.getClubs();
    notifyListeners();
  }

  void syncWithHole(CourseEntity course, int holeIndex, String teeBox) {
    _course = course;
    _currentHoleIndex = holeIndex.clamp(0, 17);
    _teeBox = teeBox;
    _targetLocation = currentHole.targetLocation;
    notifyListeners();
  }

  void updateTargetLocation(LatLng point) {
    _targetLocation = point;
    notifyListeners();
  }

  void resetTargetToCenter() {
    _targetLocation = currentHole.targetLocation;
    notifyListeners();
  }

  int getDistanceTeeToTargetYards() {
    final meters = _distance.as(
      LengthUnit.Meter,
      currentHole.teeLocation,
      targetLocation,
    );
    return (meters * 1.09361).round();
  }

  int getDistanceTargetToPinYards() {
    final meters = _distance.as(
      LengthUnit.Meter,
      targetLocation,
      currentHole.greenLocation,
    );
    return (meters * 1.09361).round();
  }

  int getDistanceToFrontPinYards() {
    final meters = _distance.as(
      LengthUnit.Meter,
      targetLocation,
      currentHole.frontPinLocation,
    );
    return (meters * 1.09361).round();
  }

  int getDistanceToBackPinYards() {
    final meters = _distance.as(
      LengthUnit.Meter,
      targetLocation,
      currentHole.backPinLocation,
    );
    return (meters * 1.09361).round();
  }

  int getPlaysLikeDistanceYards() {
    final raw = getDistanceTargetToPinYards();
    final windAdj = currentHole.windSpeedMph > 10 ? 6 : 2;
    final elevAdj = (currentHole.elevationChangeFeet / 3.0).round();
    return raw + windAdj + elevAdj;
  }

  // Live Shot Tracker
  void startShotTracking(LatLng? startPoint) {
    _isTrackingShot = true;
    _shotStartPoint = startPoint ?? currentHole.teeLocation;
    notifyListeners();
  }

  int markShotEndAndCalculate(LatLng endPoint) {
    if (_shotStartPoint == null) return 0;
    final meters = _distance.as(LengthUnit.Meter, _shotStartPoint!, endPoint);
    _lastRecordedShotDistance = (meters * 1.09361).round();
    _isTrackingShot = false;
    _shotStartPoint = null;
    notifyListeners();
    return _lastRecordedShotDistance;
  }

  Future<void> saveRecordedShot(String clubId, int distance) async {
    await _clubBagRepository.recordShot(clubId, distance);
    await _loadClubs();
    notifyListeners();
  }

  void cancelShotTracking() {
    _isTrackingShot = false;
    _shotStartPoint = null;
    notifyListeners();
  }
}
