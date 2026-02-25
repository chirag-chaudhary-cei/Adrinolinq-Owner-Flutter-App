import 'package:equatable/equatable.dart';

/// Manager Team model representing team data owned by a manager
class ManagerTeamModel extends Equatable {
  const ManagerTeamModel({
    required this.id,
    required this.managerTypeId,
    required this.name,
    required this.sportId,
    this.description,
    this.imageFile,
    this.sportName,
    this.imageUrl,
    this.creationTimestamp,
    this.minPlayers,
    this.maxPlayers,
    this.currentPlayers,
    this.deleted = false,
    this.status = true,
  });

  final int id;
  final int managerTypeId;
  final String name;
  final int sportId;
  final String? description;
  final String? imageFile;
  final String? sportName;
  final String? imageUrl;
  final String? creationTimestamp;
  final int? minPlayers;
  final int? maxPlayers;
  final int? currentPlayers;
  final bool deleted;
  final bool status;

  factory ManagerTeamModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    final teamPlayersList = json['teamPlayersList'];
    final playersFromList = teamPlayersList is List ? teamPlayersList.length : null;

    return ManagerTeamModel(
      id: json['id'] as int,
      managerTypeId: json['managerTypeId'] as int? ?? 84,
      name: json['name'] as String? ?? '',
      sportId: json['sportId'] as int? ?? 0,
      description: json['description'] as String?,
      imageFile: json['imageFile'] as String?,
      sportName: json['sportName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      creationTimestamp: json['creationTimestamp'] as String?,
      minPlayers: parseInt(json['minTeamSize']) ?? parseInt(json['minPlayers']),
      maxPlayers: parseInt(json['maxTeamSize']) ?? parseInt(json['maxPlayers']),
      currentPlayers: parseInt(json['currentPlayersCount']) ??
          parseInt(json['playersCount']) ??
          parseInt(json['teamPlayersCount']) ??
          playersFromList,
      deleted: json['deleted'] as bool? ?? false,
      status: json['status'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'managerTypeId': managerTypeId,
      'name': name,
      'sportId': sportId,
      if (description != null) 'description': description,
      if (imageFile != null) 'imageFile': imageFile,
      if (sportName != null) 'sportName': sportName,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (creationTimestamp != null) 'creationTimestamp': creationTimestamp,
      if (minPlayers != null) 'minPlayers': minPlayers,
      if (maxPlayers != null) 'maxPlayers': maxPlayers,
      if (currentPlayers != null) 'currentPlayers': currentPlayers,
      'deleted': deleted,
      'status': status,
    };
  }

  ManagerTeamModel copyWith({
    int? id,
    int? managerTypeId,
    String? name,
    int? sportId,
    String? description,
    String? imageFile,
    String? sportName,
    String? imageUrl,
    String? creationTimestamp,
    int? minPlayers,
    int? maxPlayers,
    int? currentPlayers,
    bool? deleted,
    bool? status,
  }) {
    return ManagerTeamModel(
      id: id ?? this.id,
      managerTypeId: managerTypeId ?? this.managerTypeId,
      name: name ?? this.name,
      sportId: sportId ?? this.sportId,
      description: description ?? this.description,
      imageFile: imageFile ?? this.imageFile,
      sportName: sportName ?? this.sportName,
      imageUrl: imageUrl ?? this.imageUrl,
      creationTimestamp: creationTimestamp ?? this.creationTimestamp,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      deleted: deleted ?? this.deleted,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        managerTypeId,
        name,
        sportId,
        description,
        imageFile,
        sportName,
        imageUrl,
        creationTimestamp,
        minPlayers,
        maxPlayers,
        currentPlayers,
        deleted,
        status,
      ];
}
