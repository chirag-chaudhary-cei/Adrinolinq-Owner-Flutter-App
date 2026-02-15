/// Team player model representing player data in a team from API
class TeamPlayerModel {
  const TeamPlayerModel({
    required this.id,
    required this.teamId,
    required this.playerId,
    required this.playerName,
    required this.playerMobile,
    this.playerEmail,
    required this.deleted,
    required this.status,
    this.creationTimestamp,
  });

  final int id;
  final int teamId;
  final int playerId;
  final String playerName;
  final String playerMobile;
  final String? playerEmail;
  final bool deleted;
  final bool status;
  final String? creationTimestamp;

  factory TeamPlayerModel.fromJson(Map<String, dynamic> json) {
    return TeamPlayerModel(
      id: json['id'] as int,
      teamId: json['teamId'] as int,
      playerId: json['playerId'] as int,
      playerName: json['playerName'] as String? ?? '',
      playerMobile: json['playerMobile'] as String? ?? '',
      playerEmail: json['playerEmail'] as String?,
      deleted: json['deleted'] as bool? ?? false,
      status: json['status'] as bool? ?? true,
      creationTimestamp: json['creationTimestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'playerId': playerId,
      'playerName': playerName,
      'playerMobile': playerMobile,
      'playerEmail': playerEmail,
      'deleted': deleted,
      'status': status,
      'creationTimestamp': creationTimestamp,
    };
  }
}
