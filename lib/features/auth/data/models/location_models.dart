import 'package:equatable/equatable.dart';

abstract class LocationItem extends Equatable {
  const LocationItem({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class CountryModel extends LocationItem {
  const CountryModel({required super.id, required super.name});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['countryId'] as int? ?? json['id'] as int? ?? 0,
      name: json['countryName'] as String? ??
          json['country'] as String? ??
          json['name'] as String? ??
          '',
    );
  }
}

class StateModel extends LocationItem {
  const StateModel({required super.id, required super.name, this.countryId});

  final int? countryId;

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['stateId'] as int? ?? json['id'] as int? ?? 0,
      name: json['stateName'] as String? ??
          json['state'] as String? ??
          json['name'] as String? ??
          '',
      countryId: json['countryId'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, name, countryId];
}

class DistrictModel extends LocationItem {
  const DistrictModel({required super.id, required super.name, this.stateId});

  final int? stateId;

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['districtId'] as int? ?? json['id'] as int? ?? 0,
      name: json['districtName'] as String? ??
          json['district'] as String? ??
          json['name'] as String? ??
          '',
      stateId: json['stateId'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, name, stateId];
}

class CityModel extends LocationItem {
  const CityModel({required super.id, required super.name, this.districtId});

  final int? districtId;

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['cityId'] as int? ?? json['id'] as int? ?? 0,
      name: json['cityName'] as String? ??
          json['city'] as String? ??
          json['name'] as String? ??
          '',
      districtId: json['districtId'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, name, districtId];
}

class RegionModel extends LocationItem {
  const RegionModel({required super.id, required super.name, this.cityId});

  final int? cityId;

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['regionId'] as int? ?? json['id'] as int? ?? 0,
      name: json['regionName'] as String? ??
          json['region'] as String? ??
          json['name'] as String? ??
          '',
      cityId: json['cityId'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, name, cityId];
}

class CommunityModel extends LocationItem {
  const CommunityModel(
      {required super.id, required super.name, this.regionId, this.address,});

  final int? regionId;
  final String? address;

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['communityId'] as int? ?? json['id'] as int? ?? 0,
      name: json['communityName'] as String? ?? json['name'] as String? ?? '',
      regionId: json['regionId'] as int?,
      address: json['address'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, regionId, address];
}

class LocationListResponse<T> extends Equatable {
  const LocationListResponse({
    required this.success,
    required this.items,
    this.message,
  });

  final bool success;
  final List<T> items;
  final String? message;

  @override
  List<Object?> get props => [success, items, message];
}
