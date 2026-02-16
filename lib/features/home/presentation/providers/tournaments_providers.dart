import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/cache/smart_cache.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/datasources/tournaments_remote_data_source.dart';
import '../../data/models/tournament_model.dart';
import '../../data/models/team_model.dart';
import '../../data/models/team_player_model.dart';
import '../../data/repositories/tournaments_repository.dart';
import '../../../teams/data/models/manager_team_model.dart';

/// Tournaments remote data source provider
final tournamentsRemoteDataSourceProvider =
    Provider<TournamentsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TournamentsRemoteDataSource(apiClient);
});

/// Alias for tournaments data source provider (for image URL access)
final tournamentsDataSourceProvider = tournamentsRemoteDataSourceProvider;

/// Tournaments repository provider
final tournamentsRepositoryProvider = Provider<TournamentsRepository>((ref) {
  final remoteDataSource = ref.watch(tournamentsRemoteDataSourceProvider);
  return TournamentsRepository(remoteDataSource);
});

class TournamentsNotifier extends AsyncNotifier<List<TournamentModel>> {
  bool _isRefreshing = false;

  @override
  FutureOr<List<TournamentModel>> build() async {
    ref.keepAlive();

    final repository = ref.read(tournamentsRepositoryProvider);

    final cached = repository.getCachedTournamentsList();

    if (cached != null && cached.isNotEmpty) {
      SmartCacheDebug.logCacheHit();

      SmartCacheDebug.logFetching();
      Future.microtask(() => _fetchAndCompare(cached, showIndicator: false));

      return cached;
    }

    SmartCacheDebug.logNoCache();
    return await repository.getTournamentsList();
  }

  Future<void> _fetchAndCompare(
    List<TournamentModel> currentData, {
    bool showIndicator = true,
  }) async {
    if (_isRefreshing) {
      SmartCacheDebug.logRefreshing();
      return;
    }

    _isRefreshing = true;

    try {
      final repository = ref.read(tournamentsRepositoryProvider);
      final freshData = await repository.getTournamentsList();

      if (freshData.isEmpty && currentData.isNotEmpty) {
        if (kDebugMode) {
          print('⚠️ [SmartCache] API returned empty, preserving cached data');
        }
        state = AsyncValue.data(currentData);
        _isRefreshing = false;
        return;
      }

      final hasChanged = _hasDataChanged(currentData, freshData);

      if (hasChanged) {
        state = AsyncValue.data(freshData);
        SmartCacheDebug.logDataChanged(currentData.length, freshData.length);
      } else {
        state = AsyncValue.data(currentData);
        SmartCacheDebug.logNoChange();
      }
    } catch (e) {
      state = AsyncValue.data(currentData);
      SmartCacheDebug.logFailed(e);
    } finally {
      _isRefreshing = false;
    }
  }

  bool _hasDataChanged(
    List<TournamentModel> oldData,
    List<TournamentModel> newData,
  ) {
    if (oldData.length != newData.length) return true;

    final oldIds = oldData.map((t) => t.id).toSet();
    final newIds = newData.map((t) => t.id).toSet();
    if (!oldIds.containsAll(newIds) || !newIds.containsAll(oldIds)) return true;

    for (int i = 0; i < oldData.length; i++) {
      final oldJson = oldData[i].toJson();
      final newJson = newData[i].toJson();
      if (oldJson.toString() != newJson.toString()) return true;
    }

    return false;
  }

  Future<void> forceRefresh() async {
    final currentData = state.value ?? [];
    await _fetchAndCompare(currentData, showIndicator: true);
  }
}

final tournamentsNotifierProvider =
    AsyncNotifierProvider<TournamentsNotifier, List<TournamentModel>>(
  TournamentsNotifier.new,
);

final offlineFirstTournamentsProvider = tournamentsNotifierProvider;

final tournamentsListProvider =
    FutureProvider.autoDispose<List<TournamentModel>>((ref) async {
  final repository = ref.watch(tournamentsRepositoryProvider);

  final cached = repository.getCachedTournamentsList();
  if (cached != null && cached.isNotEmpty) {
    Future.microtask(() async {
      try {
        await repository.getTournamentsList();
      } catch (_) {}
    });
    return cached;
  }

  return repository.getTournamentsList();
});

final refreshableTournamentsProvider =
    FutureProvider.autoDispose<List<TournamentModel>>((ref) async {
  final repository = ref.watch(tournamentsRepositoryProvider);
  return repository.getTournamentsList();
});

/// My Tournaments provider - fetches tournaments the user is registered for
final myTournamentsProvider =
    FutureProvider.autoDispose<List<TournamentModel>>((ref) async {
  final repository = ref.watch(tournamentsRepositoryProvider);
  return repository.getMyTournamentsList();
});

/// Manager Teams provider - fetches all teams owned by the logged-in manager
final managerTeamsListProvider =
    FutureProvider.autoDispose<List<ManagerTeamModel>>((ref) async {
  final repository = ref.watch(tournamentsRepositoryProvider);
  return repository.getManagerTeamsList();
});

final teamsListProvider = FutureProvider.autoDispose
    .family<List<TeamModel>, int>((ref, tournamentId) async {
  final repository = ref.watch(tournamentsRepositoryProvider);

  final cached = repository.getCachedTeamsList(tournamentId);
  if (cached != null && cached.isNotEmpty) {
    SmartCacheDebug.logCacheHit();
    return cached;
  }

  SmartCacheDebug.logNoCache();
  return await repository.getTeamsList(tournamentId);
});

final teamPlayersListProvider = FutureProvider.autoDispose
    .family<List<TeamPlayerModel>, int>((ref, teamId) async {
  final repository = ref.watch(tournamentsRepositoryProvider);

  final cached = repository.getCachedTeamPlayersList(teamId);
  if (cached != null && cached.isNotEmpty) {
    SmartCacheDebug.logCacheHit();
    return cached;
  }

  SmartCacheDebug.logNoCache();
  return await repository.getTeamPlayersList(teamId);
});

final saveTeamProvider =
    FutureProvider.family.autoDispose<dynamic, Map<String, dynamic>>(
  (ref, params) async {
    final repository = ref.watch(tournamentsRepositoryProvider);
    return repository.saveTeam(
      tournamentId: params['tournamentId'] as int,
      teamName: params['teamName'] as String,
      teamId: params['teamId'] as int?,
    );
  },
);

final saveTeamPlayerProvider =
    FutureProvider.family.autoDispose<dynamic, Map<String, dynamic>>(
  (ref, params) async {
    final repository = ref.watch(tournamentsRepositoryProvider);
    return repository.saveTeamPlayer(
      teamId: params['teamId'] as int,
      playerId: params['playerId'] as int,
      id: params['id'] as int?,
    );
  },
);

final tournamentByIdProvider = FutureProvider.autoDispose
    .family<TournamentModel?, int>((ref, tournamentId) async {
  final repository = ref.watch(tournamentsRepositoryProvider);

  final cached = repository.getCachedTournamentById(tournamentId);
  if (cached != null) {
    SmartCacheDebug.logCacheHit();
    return cached;
  }

  SmartCacheDebug.logNoCache();
  return await repository.getTournamentById(tournamentId);
});

final tournamentRegistrationStatusProvider =
    FutureProvider.family.autoDispose<Map<String, dynamic>?, int>(
  (ref, tournamentId) async {
    final dataSource = ref.watch(tournamentsRemoteDataSourceProvider);
    return dataSource.getTournamentRegistrationStatus(tournamentId);
  },
);

final sportRolesListProvider =
    FutureProvider.family.autoDispose<List<Map<String, dynamic>>, int>(
  (ref, sportId) async {
    final dataSource = ref.watch(tournamentsRemoteDataSourceProvider);
    return dataSource.getSportRolesList(sportId);
  },
);

final saveTournamentTeamProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>?, Map<String, dynamic>>(
  (ref, params) async {
    final dataSource = ref.watch(tournamentsRemoteDataSourceProvider);
    return dataSource.saveTournamentTeam(
      tournamentId: params['tournamentId'] as int,
      name: params['name'] as String,
      captainUserId: params['captainUserId'] as int?,
      id: params['id'] as int?,
    );
  },
);

final saveTournamentTeamPlayerProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>?, Map<String, dynamic>>(
  (ref, params) async {
    final dataSource = ref.watch(tournamentsRemoteDataSourceProvider);
    return dataSource.saveTournamentTeamPlayer(
      teamId: params['teamId'] as int,
      playerUserId: params['playerUserId'] as int,
      tournamentId: params['tournamentId'] as int?,
      sportRoleId: params['sportRoleId'] as int?,
      id: params['id'] as int?,
    );
  },
);

final saveTournamentRegistrationProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>?, Map<String, dynamic>>(
  (ref, params) async {
    final dataSource = ref.watch(tournamentsRemoteDataSourceProvider);
    return dataSource.saveTournamentRegistrations(
      teamId: params['teamId'] as int,
      tournamentId: params['tournamentId'] as int,
    );
  },
);

final saveTournamentRegistrationWithInviteCodeProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>?, Map<String, dynamic>>(
  (ref, params) async {
    final dataSource = ref.watch(tournamentsRemoteDataSourceProvider);
    return dataSource.saveTournamentRegistrationWithInviteCode(
      tournamentId: params['tournamentId'] as int,
      teamId: params['teamId'] as int,
      inviteCode: params['inviteCode'] as String,
    );
  },
);

final tournamentTeamPlayersListProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, teamId) async {
  final dataSource = ref.watch(tournamentsRemoteDataSourceProvider);
  return dataSource.getTournamentTeamPlayersList(teamId);
});

final deleteTournamentTeamPlayerProvider =
    FutureProvider.family.autoDispose<bool, int>(
  (ref, playerId) async {
    final dataSource = ref.watch(tournamentsRemoteDataSourceProvider);
    return dataSource.deleteTournamentTeamPlayer(playerId);
  },
);

final searchUserProvider =
    FutureProvider.family.autoDispose<List<Map<String, dynamic>>, String>(
  (ref, query) async {
    final dataSource = ref.watch(tournamentsRemoteDataSourceProvider);
    return dataSource.searchUserByQuery(query);
  },
);

final sponsorsListProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>(
        (ref, tournamentId) async {
  final dataSource = ref.watch(tournamentsRemoteDataSourceProvider);
  return dataSource.getTournamentSponsorsList(tournamentId);
});
