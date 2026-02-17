import 'package:equatable/equatable.dart';

/// Team Player model representing a player in a team
class TeamPlayerModel extends Equatable {
  const TeamPlayerModel({
    required this.id,
    required this.teamId,
    required this.playerUserId,
    required this.sportRoleId,
    this.playerName,
    this.mobile,
    this.email,
    this.sportRole,
    this.imageFile,
    this.proficiencyLevel,
    this.creationTimestamp,
    this.deleted = false,
    this.status = true,
  });

  final int id;
  final int teamId;
  final int playerUserId;
  final int sportRoleId;
  final String? playerName;
  final String? mobile;
  final String? email;
  final String? sportRole;
  final String? imageFile;
  final String? proficiencyLevel;
  final String? creationTimestamp;
  final bool deleted;
  final bool status;

  factory TeamPlayerModel.fromJson(Map<String, dynamic> json) {
    return TeamPlayerModel(
      id: json['id'] as int? ?? 0,
      teamId: json['teamId'] as int? ?? 0,
      playerUserId: json['playerUserId'] as int? ?? 0,
      sportRoleId: json['sportRoleId'] as int? ?? 0,
      playerName: json['playerName'] as String? ?? json['player'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      sportRole: json['sportRole'] as String?,
      imageFile: json['imageFile'] as String?,
      proficiencyLevel: json['proficiencyLevel'] as String?,
      creationTimestamp: json['creationTimestamp'] as String?,
      deleted: json['deleted'] as bool? ?? false,
      status: json['status'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'playerUserId': playerUserId,
      'sportRoleId': sportRoleId,
      if (playerName != null) 'playerName': playerName,
      if (mobile != null) 'mobile': mobile,
      if (email != null) 'email': email,
      if (sportRole != null) 'sportRole': sportRole,
      if (imageFile != null) 'imageFile': imageFile,
      if (proficiencyLevel != null) 'proficiencyLevel': proficiencyLevel,
      if (creationTimestamp != null) 'creationTimestamp': creationTimestamp,
      'deleted': deleted,
      'status': status,
    };
  }

  TeamPlayerModel copyWith({
    int? id,
    int? teamId,
    int? playerUserId,
    int? sportRoleId,
    String? playerName,
    String? mobile,
    String? email,
    String? sportRole,
    String? imageFile,
    String? proficiencyLevel,
    String? creationTimestamp,
    bool? deleted,
    bool? status,
  }) {
    return TeamPlayerModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      playerUserId: playerUserId ?? this.playerUserId,
      sportRoleId: sportRoleId ?? this.sportRoleId,
      playerName: playerName ?? this.playerName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      sportRole: sportRole ?? this.sportRole,
      imageFile: imageFile ?? this.imageFile,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      creationTimestamp: creationTimestamp ?? this.creationTimestamp,
      deleted: deleted ?? this.deleted,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        teamId,
        playerUserId,
        sportRoleId,
        playerName,
        mobile,
        email,
        sportRole,
        imageFile,
        proficiencyLevel,
        creationTimestamp,
        deleted,
        status,
      ];
}
