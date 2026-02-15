class TournamentRoundGroupTeamModel {
  final int id;
  final int tournamentRoundGroupId;
  final int tournamentTeamId;
  final bool deleted;
  final bool status;
  final String createdBy;
  final String createdDatetime;
  final String? modifiedBy;
  final String? modifiedDatetime;
  final int serialNo;

  TournamentRoundGroupTeamModel({
    required this.id,
    required this.tournamentRoundGroupId,
    required this.tournamentTeamId,
    required this.deleted,
    required this.status,
    required this.createdBy,
    required this.createdDatetime,
    this.modifiedBy,
    this.modifiedDatetime,
    required this.serialNo,
  });

  factory TournamentRoundGroupTeamModel.fromJson(Map<String, dynamic> json) {
    return TournamentRoundGroupTeamModel(
      id: json['id'] as int,
      tournamentRoundGroupId: json['tournamentRoundGroupId'] as int,
      tournamentTeamId: json['tournamentTeamId'] as int,
      deleted: json['deleted'] as bool,
      status: json['status'] as bool,
      createdBy: json['createdBy'] as String,
      createdDatetime: json['createdDatetime'] as String,
      modifiedBy: json['modifiedBy'] as String?,
      modifiedDatetime: json['modifiedDatetime'] as String?,
      serialNo: json['serialNo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentRoundGroupId': tournamentRoundGroupId,
      'tournamentTeamId': tournamentTeamId,
      'deleted': deleted,
      'status': status,
      'createdBy': createdBy,
      'createdDatetime': createdDatetime,
      'modifiedBy': modifiedBy,
      'modifiedDatetime': modifiedDatetime,
      'serialNo': serialNo,
    };
  }
}
