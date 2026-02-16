import '../datasources/tournaments_remote_data_source.dart';
import '../models/tournament_model.dart';
import '../models/team_model.dart';
import '../models/team_player_model.dart';
import '../../../teams/data/models/manager_team_model.dart';

/// Tournaments repository - handles data operations for tournaments
/// Implements offline-first strategy: returns cached data first, then refreshes from API
class TournamentsRepository {
  TournamentsRepository(this._remoteDataSource);

  final TournamentsRemoteDataSource _remoteDataSource;

  /// Get tournaments list (from API with caching)
  Future<List<TournamentModel>> getTournamentsList() async {
    return await _remoteDataSource.getTournamentsList();
  }

  /// Get cached tournaments list immediately (for offline-first display)
  List<TournamentModel>? getCachedTournamentsList() {
    return _remoteDataSource.getCachedTournamentsList();
  }

  /// Check if cached tournaments exist
  bool hasCachedTournaments() {
    return _remoteDataSource.hasCachedTournaments();
  }

  /// Get my tournaments list (tournaments I'm registered for)
  Future<List<TournamentModel>> getMyTournamentsList() async {
    return await _remoteDataSource.getMyTournamentsList();
  }

  /// Get tournament by ID (from API with caching)
  Future<TournamentModel?> getTournamentById(int tournamentId) async {
    return await _remoteDataSource.getTournamentById(tournamentId);
  }

  /// Get cached tournament by ID immediately (for offline-first display)
  TournamentModel? getCachedTournamentById(int tournamentId) {
    return _remoteDataSource.getCachedTournamentById(tournamentId);
  }

  /// Get tournament details by ID - ALWAYS fetches fresh from API (bypasses cache)
  /// Use this for detail pages to ensure complete and fresh tournament data
  Future<TournamentModel?> getTournamentDetailsFresh(int tournamentId) async {
    return await _remoteDataSource.getTournamentDetailsFresh(tournamentId);
  }

  /// Get teams list for a specific tournament
  Future<List<TeamModel>> getTeamsList(int tournamentId) async {
    return await _remoteDataSource.getTeamsList(tournamentId);
  }

  /// Get cached teams list immediately
  List<TeamModel>? getCachedTeamsList(int tournamentId) {
    return _remoteDataSource.getCachedTeamsList(tournamentId);
  }

  /// Get manager teams list (all teams owned by logged-in manager)
  Future<List<ManagerTeamModel>> getManagerTeamsList() async {
    return await _remoteDataSource.getManagerTeamsList();
  }

  /// Get team players list for a specific team
  Future<List<TeamPlayerModel>> getTeamPlayersList(int teamId) async {
    return await _remoteDataSource.getTeamPlayersList(teamId);
  }

  /// Get cached team players list immediately
  List<TeamPlayerModel>? getCachedTeamPlayersList(int teamId) {
    return _remoteDataSource.getCachedTeamPlayersList(teamId);
  }

  /// Save team (register a team for a tournament)
  Future<dynamic> saveTeam({
    required int tournamentId,
    required String teamName,
    int? teamId,
  }) async {
    return await _remoteDataSource.saveTeam(
      tournamentId: tournamentId,
      teamName: teamName,
      teamId: teamId,
    );
  }

  /// Save team player (add a player to a team)
  Future<dynamic> saveTeamPlayer({
    required int teamId,
    required int playerId,
    int? id,
  }) async {
    return await _remoteDataSource.saveTeamPlayer(
      teamId: teamId,
      playerId: playerId,
      id: id,
    );
  }

  /// Get full URL for tournament image
  String getTournamentImageUrl(String? fileName) {
    return _remoteDataSource.getTournamentImageUrl(fileName);
  }
}
