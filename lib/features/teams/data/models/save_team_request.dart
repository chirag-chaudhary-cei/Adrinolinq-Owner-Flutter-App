import 'package:equatable/equatable.dart';

/// Request model for saving/updating a manager team
class SaveTeamRequest extends Equatable {
  const SaveTeamRequest({
    this.id,
    this.managerTypeId = 84,
    required this.name,
    this.description,
    this.imageFile,
    required this.sportId,
  });

  final int? id; // Null for new team, provided for update
  final int managerTypeId; // Always 84 for manager teams
  final String name;
  final String? description;
  final String? imageFile;
  final int sportId;

  /// Validate the request
  String? validate() {
    if (name.trim().isEmpty) {
      return 'Team name is required';
    }
    if (name.length > 50) {
      return 'Team name must be 50 characters or less';
    }
    if (sportId <= 0) {
      return 'Please select a sport';
    }
    if (description != null && description!.length > 200) {
      return 'Description must be 200 characters or less';
    }
    return null;
  }

  /// Build JSON payload
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'managerTypeId': managerTypeId,
      'name': name.trim(),
      'sportId': sportId,
    };

    // Include id only when updating
    if (id != null) {
      map['id'] = id;
    }

    // Include optional fields if provided
    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description!.trim();
    }
    if (imageFile != null && imageFile!.trim().isNotEmpty) {
      map['imageFile'] = imageFile;
    }

    return map;
  }

  @override
  List<Object?> get props => [
        id,
        managerTypeId,
        name,
        description,
        imageFile,
        sportId,
      ];
}
