/// Team model representing team data from API
class TeamModel {
  const TeamModel({
    required this.id,
    required this.tournamentId,
    required this.name,
    required this.deleted,
    required this.status,
    this.creationTimestamp,
    this.createdById,
  });

  final int id;
  final int tournamentId;
  final String name;
  final bool deleted;
  final bool status;
  final String? creationTimestamp;
  final int? createdById;

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as int,
      tournamentId: json['tournamentId'] as int,
      name: json['name'] as String? ?? '',
      deleted: json['deleted'] as bool? ?? false,
      status: json['status'] as bool? ?? true,
      creationTimestamp: json['creationTimestamp'] as String?,
      createdById: json['createdById'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'name': name,
      'deleted': deleted,
      'status': status,
      'creationTimestamp': creationTimestamp,
      'createdById': createdById,
    };
  }
}
