import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/golf_courses.dart';
import '../../data/models/club_model.dart';
import '../../data/repositories/club_bag_repository.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/hole_entity.dart';
import '../../domain/usecases/caddie_strategy_usecase.dart';

class CaddieChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final CaddieRecommendation? recommendation;

  const CaddieChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendation,
  });
}

class AiCaddieController extends ChangeNotifier {
  final ClubBagRepository _clubBagRepository;
  final CaddieStrategyUseCase _caddieStrategyUseCase;

  late CourseEntity _course;
  late String _teeBox;
  int _currentHoleIndex = 0;
  List<ClubModel> _clubs = [];

  bool _isStreaming = false;
  String _streamingStatusText = '';
  final List<CaddieChatMessage> _messages = [];

  AiCaddieController(this._clubBagRepository, this._caddieStrategyUseCase) {
    _course = GolfCourses.lahoreGarrison;
    _teeBox = 'Championship Black';
    _init();
  }

  bool get isStreaming => _isStreaming;
  String get streamingStatusText => _streamingStatusText;
  List<CaddieChatMessage> get messages => List.unmodifiable(_messages);
  HoleEntity get currentHole => _course.holes[_currentHoleIndex];
  CourseEntity get course => _course;
  String get teeBox => _teeBox;

  Future<void> _init() async {
    _clubs = await _clubBagRepository.getClubs();
    _seedInitialGreeting();
  }

  void syncHoleContext(CourseEntity course, int holeIndex, String teeBox) {
    _course = course;
    _currentHoleIndex = holeIndex.clamp(0, 17);
    _teeBox = teeBox;
    notifyListeners();
  }

  void _seedInitialGreeting() {
    if (_messages.isNotEmpty) return;
    _messages.add(
      CaddieChatMessage(
        id: 'msg_welcome',
        text: 'Caddie AI online. Synchronized with hole ${currentHole.holeNumber} (${currentHole.yardageForTee(_teeBox)} yards, Par ${currentHole.par}, SI ${currentHole.strokeIndex}). Current atmospheric conditions: ${currentHole.windDirection}. How would you like to attack this hole?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendUserPrompt(String prompt) async {
    if (prompt.trim().isEmpty || _isStreaming) return;

    final userMsg = CaddieChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    notifyListeners();

    await _generateStreamingResponse(prompt);
  }

  Future<void> _generateStreamingResponse(String prompt) async {
    _isStreaming = true;
    _streamingStatusText = 'Calculating carry yardage, wind head-component & dispersion...';
    notifyListeners();

    try {
      if (_clubs.isEmpty) {
        _clubs = await _clubBagRepository.getClubs();
      }

      await Future<void>.delayed(const Duration(milliseconds: 650));

      final rec = _caddieStrategyUseCase.evaluateShot(
        hole: currentHole,
        teeBox: _teeBox,
        bag: _clubs,
      );

      String fullResponse;
      final lower = prompt.toLowerCase();

      if (lower.contains('recommend') || lower.contains('club') || lower.contains('hole')) {
        fullResponse = 'Hole ${currentHole.holeNumber} Strategy: Laser distance reads ${rec.rawYardage} yards. Factoring in ${currentHole.windDirection} (+${rec.windAdjustmentYards} yds) and ${currentHole.elevationChangeFeet} ft elevation (+${rec.elevationAdjustmentYards} yds), this shot plays like ${rec.playsLikeYardage} yards.\n\nOptimal Club: ${rec.recommendedClub.name} (${rec.recommendedClub.loft}, calibrated carry: ${rec.recommendedClub.carryYards} yds).\n\nAim line: ${rec.aimLineAdjustment}\nNotes: ${rec.strategyNotes}';
      } else if (lower.contains('putting') || lower.contains('gir') || lower.contains('front-9')) {
        fullResponse = 'Performance Trend Analysis: Your current FIR is trending at 71% with strong dispersion control. Putting efficiency sits at 1.7 putts per GIR. On firm greens, leave putts below the cup to give yourself uphill birdie opportunities. Avoid short-siding on hole ${currentHole.holeNumber}.';
      } else if (lower.contains('layup') || lower.contains('safe')) {
        fullResponse = 'Conservative Layup Route: Rather than challenging the ${currentHole.hazardsDescription}, select a 5-Iron or 6-Iron off the tee to land at the 120-yard marker. This leaves a full Pitching Wedge into the widest section of the green, eliminating double-bogey risks completely.';
      } else if (lower.contains('slice') || lower.contains('driver')) {
        fullResponse = 'Driver Slice Mitigation: Ensure ball position is positioned off the inside of your lead heel. At takeaway, maintain a wide takeaway arc and initiate the downswing with lower body rotation to prevent an out-to-in steep path. Favor a fairway target 7 yards left of center.';
      } else {
        fullResponse = 'Hole ${currentHole.holeNumber} Insight: ${rec.strategyNotes}. Recommended club for current ${rec.playsLikeYardage} yds adjusted distance is ${rec.recommendedClub.name}. Target the safe side of the green to secure a routine two-putt.';
      }

      // Token-by-token streaming simulation
      final words = fullResponse.split(' ');
      final responseId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
      var currentText = '';

      for (int i = 0; i < words.length; i++) {
        currentText += (i == 0 ? '' : ' ') + words[i];
        
        final partialMessage = CaddieChatMessage(
          id: responseId,
          text: currentText,
          isUser: false,
          timestamp: DateTime.now(),
          recommendation: i == words.length - 1 ? rec : null,
        );

        if (i == 0) {
          _messages.add(partialMessage);
        } else {
          _messages[_messages.length - 1] = partialMessage;
        }

        notifyListeners();
        await Future<void>.delayed(const Duration(milliseconds: 35));
      }
    } finally {
      _isStreaming = false;
      _streamingStatusText = '';
      notifyListeners();
    }
  }

  void clearConversation() {
    _messages.clear();
    _seedInitialGreeting();
    notifyListeners();
  }
}
