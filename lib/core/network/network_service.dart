import 'package:dio/dio.dart';
import 'mock_network_interceptor.dart';
import '../storage/preferences_service.dart';

class NetworkService {
  final Dio dio;

  NetworkService._(this.dio);

  factory NetworkService.create(PreferencesService prefs) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.golfer.championship.internal',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(MockNetworkInterceptor(prefs));

    return NetworkService._(dio);
  }

  Future<Map<String, dynamic>> fetchLiveTournamentLeaderboard() async {
    final response = await dio.get<Map<String, dynamic>>('/tournament/leaderboard');
    return response.data ?? {};
  }
}
