/// Match model representing match data from API
class MatchModel {
  const MatchModel({
    required this.id,
    required this.creationTimestamp,
    required this.createdById,
    required this.tournamentRoundId,
    required this.tournamentRoundGroupId,
    required this.matchStatusId,
    required this.matchDatetime,
    required this.teamSheetVerificationStatus,
    required this.deleted,
    required this.status,
  });

  final int id;
  final String creationTimestamp;
  final int createdById;
  final int tournamentRoundId;
  final int tournamentRoundGroupId;
  final int matchStatusId;
  final String matchDatetime;
  final bool teamSheetVerificationStatus;
  final bool deleted;
  final bool status;

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as int? ?? 0,
      creationTimestamp: json['creationTimestamp'] as String? ?? '',
      createdById: json['createdById'] as int? ?? 0,
      tournamentRoundId: json['tournamentRoundId'] as int? ?? 0,
      tournamentRoundGroupId: json['tournamentRoundGroupId'] as int? ?? 0,
      matchStatusId: json['matchStatusId'] as int? ?? 0,
      matchDatetime: json['matchDatetime'] as String? ?? '',
      teamSheetVerificationStatus:
          json['teamSheetVerificationStatus'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      status: json['status'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creationTimestamp': creationTimestamp,
      'createdById': createdById,
      'tournamentRoundId': tournamentRoundId,
      'tournamentRoundGroupId': tournamentRoundGroupId,
      'matchStatusId': matchStatusId,
      'matchDatetime': matchDatetime,
      'teamSheetVerificationStatus': teamSheetVerificationStatus,
      'deleted': deleted,
      'status': status,
    };
  }
}
