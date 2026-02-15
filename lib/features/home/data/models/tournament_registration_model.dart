/// Model for tournament registration status
class TournamentRegistrationModel {
  final int id;
  final int teamId;
  final int playerUserId;
  final int tournamentId;
  final bool status;

  const TournamentRegistrationModel({
    required this.id,
    required this.teamId,
    required this.playerUserId,
    required this.tournamentId,
    required this.status,
  });

  factory TournamentRegistrationModel.fromJson(Map<String, dynamic> json) {
    return TournamentRegistrationModel(
      id: json['id'] as int? ?? 0,
      teamId: json['teamId'] as int? ?? 0,
      playerUserId: json['playerUserId'] as int? ?? 0,
      tournamentId: json['tournamentId'] as int? ?? 0,
      status: json['status'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'playerUserId': playerUserId,
      'tournamentId': tournamentId,
      'status': status,
    };
  }
}
