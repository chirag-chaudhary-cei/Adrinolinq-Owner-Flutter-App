/// Model representing a tournament team from getMyTeam API
class MyTeamModel {
  const MyTeamModel({
    required this.id,
    this.creationTimestamp,
    this.createdById,
    required this.tournamentId,
    required this.captainUserId,
    required this.name,
    required this.minTeamSize,
    required this.maxTeamSize,
    required this.deleted,
    this.deletedTimestamp,
    this.deletedById,
    required this.status,
    required this.teamPlayersList,
  });

  final int id;
  final String? creationTimestamp;
  final int? createdById;
  final int tournamentId;
  final int captainUserId;
  final String name;
  final int minTeamSize;
  final int maxTeamSize;
  final bool deleted;
  final String? deletedTimestamp;
  final int? deletedById;
  final bool status;
  final List<MyTeamPlayerModel> teamPlayersList;

  factory MyTeamModel.fromJson(Map<String, dynamic> json) {
    final playersList = json['teamPlayersList'] as List<dynamic>? ?? [];
    return MyTeamModel(
      id: json['id'] as int,
      creationTimestamp: json['creationTimestamp'] as String?,
      createdById: json['createdById'] as int?,
      tournamentId: json['tournamentId'] as int? ?? 0,
      captainUserId: json['captainUserId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      minTeamSize: json['minTeamSize'] as int? ?? 1,
      maxTeamSize: json['maxTeamSize'] as int? ?? 12,
      deleted: json['deleted'] as bool? ?? false,
      deletedTimestamp: json['deletedTimestamp'] as String?,
      deletedById: json['deletedById'] as int?,
      status: json['status'] as bool? ?? true,
      teamPlayersList: playersList
          .map((e) => MyTeamPlayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model representing a single player in the team
class MyTeamPlayerModel {
  const MyTeamPlayerModel({
    required this.id,
    this.creationTimestamp,
    this.createdById,
    required this.teamId,
    required this.tournamentId,
    required this.playerUserId,
    required this.player,
    this.imageFile,
    this.proficiencyLevel,
    this.inviteStatus,
    required this.deleted,
    required this.status,
  });

  final int id;
  final String? creationTimestamp;
  final int? createdById;
  final int teamId;
  final int tournamentId;
  final int playerUserId;
  final String player;
  final String? imageFile;
  final String? proficiencyLevel;
  final int? inviteStatus; // 0=Pending, 1=Accepted, 2=Rejected
  final bool deleted;
  final bool status;

  /// Human-readable invite status
  String get inviteStatusText {
    switch (inviteStatus) {
      case 0:
        return 'Pending';
      case 1:
        return 'Accepted';
      case 2:
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  factory MyTeamPlayerModel.fromJson(Map<String, dynamic> json) {
    return MyTeamPlayerModel(
      id: json['id'] as int,
      creationTimestamp: json['creationTimestamp'] as String?,
      createdById: json['createdById'] as int?,
      teamId: json['teamId'] as int? ?? 0,
      tournamentId: json['tournamentId'] as int? ?? 0,
      playerUserId: json['playerUserId'] as int? ?? 0,
      player: json['player'] as String? ?? 'Unknown Player',
      imageFile: json['imageFile'] as String?,
      proficiencyLevel: json['proficiencyLevel'] as String?,
      inviteStatus: json['inviteStatus'] as int?,
      deleted: json['deleted'] as bool? ?? false,
      status: json['status'] as bool? ?? true,
    );
  }
}
