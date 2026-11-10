import 'dart:math';

import 'package:dio/dio.dart';

import '../storage/preferences_service.dart';

class MockNetworkInterceptor extends Interceptor {
  final PreferencesService _prefs;
  final Random _random = Random();

  MockNetworkInterceptor(this._prefs);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final simulateLatency = _prefs.getSimulateLatency();
    final simulateError = _prefs.getSimulateError();

    if (simulateLatency) {
      final delayMs = 400 + _random.nextInt(400); // 400ms - 800ms
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }

    if (simulateError) {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            statusMessage:
                'Service Unavailable (Simulated Recruiter Debug Error)',
            data: {
              'error': 'Tournament server unreachable. Offline local persistence active.',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
    }

    // Intercept and mock responses for cloud sync endpoints
    if (options.path.contains('/tournament/leaderboard')) {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'tournament': 'Lahore Garrison Autumn Open',
            'status': 'Live - Round 3',
            'leaders': [
              {'rank': 1, 'player': 'Hamza Amin', 'score': -8, 'thru': 18},
              {'rank': 2, 'player': 'Safeer Hussain', 'score': -5, 'thru': 14},
              {'rank': 3, 'player': 'Shabbir Iqbal', 'score': -4, 'thru': 16},
              {'rank': 4, 'player': 'Matloob Ahmed', 'score': -2, 'thru': 18},
              {'rank': 5, 'player': 'M. Khan', 'score': 1, 'thru': 18},
            ],
          },
        ),
      );
    }

    return handler.next(options);
  }
}
