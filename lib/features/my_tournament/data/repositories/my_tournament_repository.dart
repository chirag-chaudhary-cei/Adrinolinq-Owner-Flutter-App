import '../datasources/my_tournament_remote_data_source.dart';
import '../models/tournament_registration_model.dart';
import '../models/tournament_team_player_model.dart';
import '../models/my_team_model.dart';

/// My Tournament repository - handles business logic for tournament registrations
class MyTournamentRepository {
  MyTournamentRepository({required this.remoteDataSource});

  final MyTournamentRemoteDataSource remoteDataSource;

  Future<List<TournamentRegistrationModel>> getTournamentRegistrations() async {
    return remoteDataSource.getTournamentRegistrations();
  }

  List<TournamentRegistrationModel>? getCachedRegistrations() {
    return remoteDataSource.getCachedRegistrations();
  }

  Future<List<TournamentTeamPlayerModel>> getTournamentTeamPlayers(
    int teamId,
  ) async {
    return remoteDataSource.getTournamentTeamPlayers(teamId);
  }

  List<TournamentTeamPlayerModel>? getCachedTeamPlayers(int teamId) {
    return remoteDataSource.getCachedTeamPlayers(teamId);
  }

  Future<void> clearCache() async {
    await remoteDataSource.clearCache();
  }

  Future<void> clearTeamPlayersCache(int teamId) async {
    await remoteDataSource.clearTeamPlayersCache(teamId);
  }

  String getTournamentImageUrl(String? imageFile) {
    return remoteDataSource.getTournamentImageUrl(imageFile);
  }

  Future<List<Map<String, dynamic>>> getEnrolledPlayers(
    int tournamentId,
  ) async {
    return remoteDataSource.getEnrolledPlayers(tournamentId);
  }

  Future<List<Map<String, dynamic>>> getCurrentAuctionTimeline(
    int tournamentId,
  ) async {
    return remoteDataSource.getCurrentAuctionTimeline(tournamentId);
  }

  Future<Map<String, dynamic>> savePlayerAuctionBid(
      int playerAuctionId, int points, int tournamentTeamId) async {
    return remoteDataSource.savePlayerAuctionBid(
        playerAuctionId, points, tournamentTeamId);
  }

  Future<Map<String, dynamic>> getUserDetails(int userId) async {
    return remoteDataSource.getUserDetails(userId);
  }

  MyTeamModel? getCachedMyTeam(int tournamentId) {
    return remoteDataSource.getCachedMyTeam(tournamentId);
  }

  Future<MyTeamModel?> getMyTeam(int tournamentId) async {
    return remoteDataSource.getMyTeam(tournamentId);
  }
}
