/// Team player model representing player data in a team from API
class TeamPlayerModel {
  const TeamPlayerModel({
    required this.id,
    required this.teamId,
    required this.playerUserId,
    required this.playerName,
    this.sportRoleId,
    this.sportRole,
    this.imageFile,
    this.proficiencyLevel,
    required this.deleted,
    required this.status,
    this.creationTimestamp,
  });

  final int id;
  final int teamId;
  final int playerUserId;
  final String playerName;
  final int? sportRoleId;
  final String? sportRole;
  final String? imageFile;
  final String? proficiencyLevel;
  final bool deleted;
  final bool status;
  final String? creationTimestamp;

  factory TeamPlayerModel.fromJson(Map<String, dynamic> json) {
    return TeamPlayerModel(
      id: json['id'] as int? ?? 0,
      teamId: json['teamId'] as int? ?? 0,
      playerUserId: json['playerUserId'] as int? ?? 0,
      playerName:
          json['player'] as String? ?? json['playerName'] as String? ?? '',
      sportRoleId: json['sportRoleId'] as int?,
      sportRole: json['sportRole'] as String?,
      imageFile: json['imageFile'] as String?,
      proficiencyLevel: json['proficiencyLevel'] as String?,
      deleted: json['deleted'] as bool? ?? false,
      status: json['status'] as bool? ?? true,
      creationTimestamp: json['creationTimestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'playerUserId': playerUserId,
      'player': playerName,
      if (sportRoleId != null) 'sportRoleId': sportRoleId,
      if (sportRole != null) 'sportRole': sportRole,
      if (imageFile != null) 'imageFile': imageFile,
      if (proficiencyLevel != null) 'proficiencyLevel': proficiencyLevel,
      'deleted': deleted,
      'status': status,
      if (creationTimestamp != null) 'creationTimestamp': creationTimestamp,
    };
  }
}
