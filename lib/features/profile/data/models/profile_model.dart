import 'package:equatable/equatable.dart';

/// User profile model
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.nameTitleId,
    this.genderId,
    this.gender,
    this.dob,
    this.bloodGroupId,
    this.bloodGroup,
    this.height,
    this.weight,
    this.tshirtSizeId,
    this.tshirtSize,
    this.foodPreferenceId,
    this.street,
    this.pincode,
    this.countryId,
    this.country,
    this.stateId,
    this.state,
    this.districtId,
    this.district,
    this.cityId,
    this.city,
    this.region,
    this.imageFile,
    this.sports,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobile;
  final int? nameTitleId;
  final int? genderId;
  final String? gender;
  final String? dob;
  final int? bloodGroupId;
  final String? bloodGroup;
  final double? height;
  final double? weight;
  final int? tshirtSizeId;
  final String? tshirtSize;
  final int? foodPreferenceId;
  final String? street;
  final String? pincode;
  final int? countryId;
  final String? country;
  final int? stateId;
  final String? state;
  final int? districtId;
  final String? district;
  final int? cityId;
  final String? city;
  final String? region;
  final String? imageFile;
  final List<UserSport>? sports;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      nameTitleId: json['nameTitleId'] as int?,
      genderId: json['genderId'] as int?,
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      bloodGroupId: json['bloodGroupId'] as int?,
      bloodGroup: json['bloodGroup']?.toString(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      tshirtSizeId: json['tshirtSizeId'] as int?,
      tshirtSize: json['tshirtSize']?.toString(),
      foodPreferenceId: json['foodPreferenceId'] as int?,
      street: json['street']?.toString(),
      pincode: json['pincode']?.toString(),
      countryId: json['countryId'] as int?,
      country: json['country']?.toString(),
      stateId: json['stateId'] as int?,
      state: json['state']?.toString(),
      districtId: json['districtId'] as int?,
      district: json['district']?.toString(),
      cityId: json['cityId'] as int?,
      city: json['city']?.toString(),
      region: json['region']?.toString(),
      imageFile: json['imageFile']?.toString(),
      sports: (json['sports'] as List<dynamic>?)
          ?.map((e) => UserSport.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'id': id,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (email != null) 'email': email,
      if (mobile != null) 'mobile': mobile,
      if (nameTitleId != null) 'nameTitleId': nameTitleId,
      if (genderId != null) 'genderId': genderId,
      if (dob != null) 'dob': dob,
      if (bloodGroupId != null) 'bloodGroupId': bloodGroupId,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (tshirtSizeId != null) 'tshirtSizeId': tshirtSizeId,
      if (foodPreferenceId != null) 'foodPreferenceId': foodPreferenceId,
      if (street != null) 'street': street,
      if (pincode != null) 'pincode': pincode,
      if (countryId != null) 'countryId': countryId,
      if (stateId != null) 'stateId': stateId,
      if (districtId != null) 'districtId': districtId,
      if (cityId != null) 'cityId': cityId,
      if (region != null) 'region': region,
      if (imageFile != null) 'imageFile': imageFile,
      if (sports != null) 'sports': sports!.map((s) => s.toJson()).toList(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? mobile,
    int? nameTitleId,
    int? genderId,
    String? dob,
    int? bloodGroupId,
    double? height,
    double? weight,
    int? tshirtSizeId,
    int? foodPreferenceId,
    String? street,
    String? pincode,
    int? countryId,
    int? stateId,
    int? districtId,
    int? cityId,
    String? region,
    String? imageFile,
    List<UserSport>? sports,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      nameTitleId: nameTitleId ?? this.nameTitleId,
      genderId: genderId ?? this.genderId,
      dob: dob ?? this.dob,
      bloodGroupId: bloodGroupId ?? this.bloodGroupId,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      tshirtSizeId: tshirtSizeId ?? this.tshirtSizeId,
      foodPreferenceId: foodPreferenceId ?? this.foodPreferenceId,
      street: street ?? this.street,
      pincode: pincode ?? this.pincode,
      countryId: countryId ?? this.countryId,
      stateId: stateId ?? this.stateId,
      districtId: districtId ?? this.districtId,
      cityId: cityId ?? this.cityId,
      region: region ?? this.region,
      imageFile: imageFile ?? this.imageFile,
      sports: sports ?? this.sports,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        mobile,
        nameTitleId,
        genderId,
        gender,
        dob,
        bloodGroupId,
        bloodGroup,
        height,
        weight,
        tshirtSizeId,
        tshirtSize,
        street,
        pincode,
        countryId,
        country,
        stateId,
        state,
        districtId,
        district,
        cityId,
        city,
        region,
        imageFile,
        sports,
      ];
}

/// User sport model
class UserSport extends Equatable {
  const UserSport({
    required this.sportsId,
    required this.proficiencyId,
  });

  final int sportsId;
  final int proficiencyId;

  factory UserSport.fromJson(Map<String, dynamic> json) {
    return UserSport(
      sportsId: json['sportsId'] as int,
      proficiencyId: json['proficiencyId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sportsId': sportsId,
      'proficiencyId': proficiencyId,
    };
  }

  @override
  List<Object?> get props => [sportsId, proficiencyId];
}
