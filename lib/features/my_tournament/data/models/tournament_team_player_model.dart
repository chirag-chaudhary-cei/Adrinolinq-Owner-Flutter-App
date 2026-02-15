/// Tournament Team Player model representing team player data from API
class TournamentTeamPlayerModel {
  const TournamentTeamPlayerModel({
    required this.id,
    required this.teamId,
    required this.tournamentId,
    required this.playerUserId,
    required this.player,
  });

  final int id;
  final int teamId;
  final int tournamentId;
  final int playerUserId;
  final String player;

  factory TournamentTeamPlayerModel.fromJson(Map<String, dynamic> json) {
    return TournamentTeamPlayerModel(
      id: json['id'] as int,
      teamId: json['teamId'] as int? ?? 0,
      tournamentId: json['tournamentId'] as int? ?? 0,
      playerUserId: json['playerUserId'] as int? ?? 0,
      player: json['player'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'tournamentId': tournamentId,
      'playerUserId': playerUserId,
      'player': player,
    };
  }
}
