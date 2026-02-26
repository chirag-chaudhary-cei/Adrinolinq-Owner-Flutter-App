import 'package:equatable/equatable.dart';

class SaveUserRequest extends Equatable {
  const SaveUserRequest({
    required this.id,
    this.nameTitleId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.email,
    this.dob,
    this.genderId,
    this.bloodGroupId,
    this.height,
    this.weight,
    this.tshirtSizeId,
    this.street,
    this.countryId,
    this.stateId,
    this.districtId,
    this.cityId,
    this.region,
    this.pincode,
    this.imageFile,
    this.roleId = 5, // Default roleId for owner
    this.foodPreferenceId,
  });

  final int id;
  final int? nameTitleId;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? mobile;
  final String? email;
  final String? dob;
  final int? genderId;
  final int? bloodGroupId;
  final double? height;
  final double? weight;
  final int? tshirtSizeId;
  final String? street;
  final int? countryId;
  final int? stateId;
  final int? districtId;
  final int? cityId;
  final String? region;
  final int? pincode;
  final String? imageFile;
  final int roleId;
  final int? foodPreferenceId;

  /// Build JSON payload with only the provided (non-null) fields + id.
  /// This ensures we only send changed data to the API.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'roleId': roleId,
    };

    // Always send the fields because the user might be clearing them out.
    // If the field is null, we pass it as null or empty string so the API clears it.
    map['nameTitleId'] = nameTitleId;
    map['firstName'] = firstName;
    map['middleName'] = middleName;
    map['lastName'] = lastName;
    map['mobile'] = mobile;
    map['email'] = email;
    map['dob'] = dob;
    map['genderId'] = genderId;
    map['bloodGroupId'] = bloodGroupId;
    map['height'] = height;
    map['weight'] = weight;
    map['tshirtSizeId'] = tshirtSizeId;
    map['street'] = street;
    map['countryId'] = countryId;
    map['stateId'] = stateId;
    map['districtId'] = districtId;
    map['cityId'] = cityId;
    map['region'] = region;
    map['pincode'] = pincode;
    map['foodPreferenceId'] = foodPreferenceId;
    map['imageFile'] = imageFile;

    return map;
  }

  @override
  List<Object?> get props => [
        id,
        nameTitleId,
        firstName,
        middleName,
        lastName,
        mobile,
        email,
        dob,
        genderId,
        bloodGroupId,
        height,
        weight,
        tshirtSizeId,
        street,
        countryId,
        stateId,
        districtId,
        cityId,
        region,
        pincode,
        imageFile,
        roleId,
        foodPreferenceId,
      ];
}

class SaveUserResponse extends Equatable {
  const SaveUserResponse({
    required this.success,
    this.message,
    this.userId,
  });

  final bool success;
  final String? message;
  final int? userId;

  factory SaveUserResponse.fromJson(Map<String, dynamic> json) {
    final responseCode = json['response_code'] as String?;
    final isSuccess = responseCode == '200';
    final obj = json['obj'];

    int? userId;
    String? message;

    if (obj is Map<String, dynamic>) {
      userId = obj['userId'] as int?;
      message = obj['message'] as String?;
    } else if (obj is String) {
      message = obj;
    }

    return SaveUserResponse(
      success: isSuccess,
      message: message,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [success, message, userId];
}
