import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/match_model.dart';

class MatchesRepository {
  final ApiClient _apiClient;

  MatchesRepository(this._apiClient);

  /// Get tournament round matches list
  /// If tournamentId is null, returns all matches
  /// If tournamentId is provided, filters matches for that tournament
  Future<List<MatchModel>> getTournamentRoundMatchesList([
    int? tournamentId,
  ]) async {
    try {
      if (kDebugMode) {
        print(
          '🎾 [MatchesRepo] Fetching matches${tournamentId != null ? " for tournamentId: $tournamentId" : " (all)"}',
        );
      }

      final Map<String, dynamic> requestData = {};
      if (tournamentId != null) {
        requestData['tournamentId'] = tournamentId;
      }

      final response = await _apiClient.post(
        ApiEndpoints.getTournamentRoundMatchesList,
        data: requestData,
      );

      if (response.statusCode == 200 &&
          response.data['response_code'] == '200') {
        final List<dynamic> data = response.data['obj'] ?? [];

        if (kDebugMode) {
          print('✅ [MatchesRepo] Fetched ${data.length} matches');
        }

        return data.map((json) => MatchModel.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print(
            '❌ [MatchesRepo] Failed to fetch matches: ${response.statusCode} - ${response.data}',
          );
        }
        return [];
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [MatchesRepo] Dio Error fetching matches: ${e.message}');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MatchesRepo] Error fetching matches: $e');
      }
      return [];
    }
  }
}
