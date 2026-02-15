/// Model for sport-specific roles (e.g., Captain, Wicket-Keeper, Opener)
class SportRoleModel {
  final int? id;
  final int? sportId;
  final String sport;
  final String name;
  final String description;
  final String shortName;
  final bool status;
  final bool deleted;

  const SportRoleModel({
    this.id,
    this.sportId,
    this.sport = '',
    this.name = '',
    this.description = '',
    this.shortName = '',
    this.status = true,
    this.deleted = false,
  });

  factory SportRoleModel.fromJson(Map<String, dynamic> json) {
    return SportRoleModel(
      id: json['id'] as int?,
      sportId: json['sportId'] as int?,
      sport: json['sport'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      shortName: json['shortName'] as String? ?? '',
      status: json['status'] as bool? ?? true,
      deleted: json['deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (sportId != null) 'sportId': sportId,
      'sport': sport,
      'name': name,
      'description': description,
      'shortName': shortName,
      'status': status,
      'deleted': deleted,
    };
  }

  @override
  String toString() => name;
}
