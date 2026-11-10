import 'package:flutter/material.dart';

import '../../domain/entities/green_reading_entity.dart';
import '../../domain/usecases/green_reading_usecase.dart';

class GreenReadingController extends ChangeNotifier {
  final GreenReadingUseCase _useCase;

  GreenSlopeReading _reading = const GreenSlopeReading(
    slopeDegrees: 1.5,
    fallLineHeadingDegrees: 90.0, // Fall line heading East
    stimpSpeed: 10.5, // Country Club standard stimp
    puttDistanceFeet: 15.0,
    puttHeadingDegrees: 0.0, // Putting North
  );

  GreenReadingController(this._useCase);

  GreenSlopeReading get reading => _reading;

  PuttCalculationResult get calculationResult => _useCase.calculatePuttBreak(
    slopeDegrees: _reading.slopeDegrees,
    fallLineHeadingDegrees: _reading.fallLineHeadingDegrees,
    stimpSpeed: _reading.stimpSpeed,
    puttDistanceFeet: _reading.puttDistanceFeet,
    puttHeadingDegrees: _reading.puttHeadingDegrees,
  );

  void setSlopeDegrees(double degrees) {
    _reading = _reading.copyWith(slopeDegrees: degrees.clamp(0.0, 6.0));
    notifyListeners();
  }

  void setFallLineHeading(double heading) {
    _reading = _reading.copyWith(fallLineHeadingDegrees: (heading % 360.0));
    notifyListeners();
  }

  void setStimpSpeed(double stimp) {
    _reading = _reading.copyWith(stimpSpeed: stimp.clamp(8.0, 13.5));
    notifyListeners();
  }

  void setPuttDistance(double distanceFeet) {
    _reading = _reading.copyWith(
      puttDistanceFeet: distanceFeet.clamp(3.0, 60.0),
    );
    notifyListeners();
  }

  void setPuttHeading(double heading) {
    _reading = _reading.copyWith(puttHeadingDegrees: (heading % 360.0));
    notifyListeners();
  }

  void applyPreset({
    required double slopeDegrees,
    required double fallLineHeading,
    required double stimpSpeed,
    double puttDistance = 15.0,
  }) {
    _reading = _reading.copyWith(
      slopeDegrees: slopeDegrees,
      fallLineHeadingDegrees: fallLineHeading,
      stimpSpeed: stimpSpeed,
      puttDistanceFeet: puttDistance,
    );
    notifyListeners();
  }
}
