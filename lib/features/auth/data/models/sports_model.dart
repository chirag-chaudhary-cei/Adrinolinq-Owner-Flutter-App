import 'package:equatable/equatable.dart';

class SportsModel extends Equatable {
  const SportsModel({
    required this.sportsId,
    required this.sportsName,
    this.imageFile,
    this.imageUrl,
  });

  final int sportsId;
  final String sportsName;
  final String? imageFile;
  final String? imageUrl;

  factory SportsModel.fromJson(Map<String, dynamic> json) {
    return SportsModel(
      sportsId: json['sportsId'] as int? ?? json['id'] as int,
      sportsName: json['sportsName'] as String? ?? json['name'] as String,
      imageFile: json['imageFile'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sportsId': sportsId,
      'sportsName': sportsName,
      if (imageFile != null) 'imageFile': imageFile,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [sportsId, sportsName, imageFile, imageUrl];
}
