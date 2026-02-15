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

    if (nameTitleId != null && nameTitleId! > 0)
      map['nameTitleId'] = nameTitleId;
    if (firstName != null && firstName!.isNotEmpty)
      map['firstName'] = firstName;
    if (middleName != null && middleName!.trim().isNotEmpty) {
      map['middleName'] = middleName!.trim();
    }
    if (lastName != null && lastName!.isNotEmpty) map['lastName'] = lastName;
    if (mobile != null && mobile!.isNotEmpty) map['mobile'] = mobile;
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (dob != null && dob!.trim().isNotEmpty) map['dob'] = dob;
    if (genderId != null && genderId! > 0) map['genderId'] = genderId;
    if (bloodGroupId != null && bloodGroupId! > 0) {
      map['bloodGroupId'] = bloodGroupId;
    }
    if (height != null && height! > 0) map['height'] = height;
    if (weight != null && weight! > 0) map['weight'] = weight;
    if (tshirtSizeId != null && tshirtSizeId! > 0) {
      map['tshirtSizeId'] = tshirtSizeId;
    }
    if (street != null && street!.trim().isNotEmpty) map['street'] = street;
    if (countryId != null && countryId! > 0) map['countryId'] = countryId;
    if (stateId != null && stateId! > 0) map['stateId'] = stateId;
    if (districtId != null && districtId! > 0) map['districtId'] = districtId;
    if (cityId != null && cityId! > 0) map['cityId'] = cityId;
    if (region != null && region!.trim().isNotEmpty) map['region'] = region;
    if (pincode != null && pincode! > 0) map['pincode'] = pincode;
    if (foodPreferenceId != null && foodPreferenceId! > 0) {
      map['foodPreferenceId'] = foodPreferenceId;
    }
    if (imageFile != null && imageFile!.trim().isNotEmpty) {
      map['imageFile'] = imageFile;
    }

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
