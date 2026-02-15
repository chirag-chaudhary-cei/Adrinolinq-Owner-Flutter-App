class TournamentTeamModel {
  final int id;
  final int tournamentId;
  final String teamName;
  final bool deleted;
  final bool status;
  final String createdBy;
  final String createdDatetime;
  final String? modifiedBy;
  final String? modifiedDatetime;

  TournamentTeamModel({
    required this.id,
    required this.tournamentId,
    required this.teamName,
    required this.deleted,
    required this.status,
    required this.createdBy,
    required this.createdDatetime,
    this.modifiedBy,
    this.modifiedDatetime,
  });

  factory TournamentTeamModel.fromJson(Map<String, dynamic> json) {
    return TournamentTeamModel(
      id: json['id'] as int,
      tournamentId: json['tournamentId'] as int,
      teamName: json['teamName'] as String,
      deleted: json['deleted'] as bool,
      status: json['status'] as bool,
      createdBy: json['createdBy'] as String,
      createdDatetime: json['createdDatetime'] as String,
      modifiedBy: json['modifiedBy'] as String?,
      modifiedDatetime: json['modifiedDatetime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'teamName': teamName,
      'deleted': deleted,
      'status': status,
      'createdBy': createdBy,
      'createdDatetime': createdDatetime,
      'modifiedBy': modifiedBy,
      'modifiedDatetime': modifiedDatetime,
    };
  }
}
