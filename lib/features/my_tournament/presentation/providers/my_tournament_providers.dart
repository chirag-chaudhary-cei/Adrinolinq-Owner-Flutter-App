import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/datasources/my_tournament_remote_data_source.dart';
import '../../data/repositories/my_tournament_repository.dart';
import '../../data/models/tournament_registration_model.dart';
import '../../data/models/tournament_team_player_model.dart';

/// My Tournament remote data source provider
final myTournamentRemoteDataSourceProvider =
    Provider<MyTournamentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MyTournamentRemoteDataSource(apiClient);
});

/// My Tournament repository provider
final myTournamentRepositoryProvider = Provider<MyTournamentRepository>((ref) {
  final remoteDataSource = ref.watch(myTournamentRemoteDataSourceProvider);
  return MyTournamentRepository(remoteDataSource: remoteDataSource);
});

/// Tournament registrations provider - fetches user's registered tournaments
/// API uses token to identify user (no need to pass user_id)
final myTournamentRegistrationsProvider =
    FutureProvider<List<TournamentRegistrationModel>>((ref) async {
  final repository = ref.watch(myTournamentRepositoryProvider);
  return repository.getTournamentRegistrations();
});

/// Tournament team players provider - fetches team players for a specific team
final tournamentTeamPlayersProvider =
    FutureProvider.family<List<TournamentTeamPlayerModel>, int>(
        (ref, teamId) async {
  final repository = ref.watch(myTournamentRepositoryProvider);

  final cached = repository.getCachedTeamPlayers(teamId);
  if (cached != null && cached.isNotEmpty) {
    Future.microtask(() async {
      try {
        await repository.getTournamentTeamPlayers(teamId);
      } catch (_) {}
    });
    return cached;
  }

  return repository.getTournamentTeamPlayers(teamId);
});

/// Enrolled players provider - fetches enrolled players for a tournament
final enrolledPlayersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>(
        (ref, tournamentId) async {
  final repository = ref.watch(myTournamentRepositoryProvider);
  return repository.getEnrolledPlayers(tournamentId);
});
