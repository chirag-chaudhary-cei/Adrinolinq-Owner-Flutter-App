/// Tournament Registration model representing registered tournaments from API
class TournamentRegistrationModel {
  const TournamentRegistrationModel({
    required this.id,
    required this.creationTimestamp,
    this.createdById,
    required this.playerUserId,
    required this.tournamentId,
    this.inviteCode,
    required this.deleted,
    required this.status,
    this.playerUserFirstName,
    this.playerUserLastName,
    this.playerUserMobile,
    this.tournamentName,
    this.tournamentDate,
    this.tournamentEndDate,
    this.tournamentImageFile,
    this.tournamentSportId,
    this.tournamentSport,
    this.tournamentFeesAmount,
    this.tournamentLocation,
    this.tournamentCountry,
    this.tournamentState,
    this.tournamentDistrict,
    this.tournamentCity,
    this.tournamentRegion,
    this.tournamentMaxRegistrations,
    this.teamId,
    this.teamName,
    this.registrationStatusId,
    this.registrationStatus,
    this.paymentStatusId,
    this.paymentStatus,
    this.paymentId,
    this.paymentDate,
    this.paymentAmount,
    this.deletedTimestamp,
    this.deletedById,
  });

  final int id;
  final String creationTimestamp;
  final int? createdById;
  final int playerUserId;
  final int tournamentId;
  final String? inviteCode;
  final bool deleted;
  final bool status;

  final String? playerUserFirstName;
  final String? playerUserLastName;
  final String? playerUserMobile;
  final String? tournamentName;
  final String? tournamentDate;
  final String? tournamentEndDate;
  final String? tournamentImageFile;
  final int? tournamentSportId;
  final String? tournamentSport;
  final double? tournamentFeesAmount;
  final String? tournamentLocation;
  final String? tournamentCountry;
  final String? tournamentState;
  final String? tournamentDistrict;
  final String? tournamentCity;
  final String? tournamentRegion;
  final int? tournamentMaxRegistrations;
  final int? teamId;
  final String? teamName;
  final int? registrationStatusId;
  final String? registrationStatus;
  final int? paymentStatusId;
  final String? paymentStatus;
  final String? paymentId;
  final String? paymentDate;
  final double? paymentAmount;
  final String? deletedTimestamp;
  final int? deletedById;

  factory TournamentRegistrationModel.fromJson(Map<String, dynamic> json) {
    return TournamentRegistrationModel(
      id: json['id'] as int,
      creationTimestamp: json['creationTimestamp'] as String? ?? '',
      createdById: json['createdById'] as int?,
      playerUserId: json['playerUserId'] as int? ?? 0,
      tournamentId: json['tournamentId'] as int? ?? 0,
      inviteCode: json['inviteCode'] as String?,
      deleted: json['deleted'] as bool? ?? false,
      status: json['status'] as bool? ?? true,
      playerUserFirstName: json['playerUserFirstName'] as String?,
      playerUserLastName: json['playerUserLastName'] as String?,
      playerUserMobile: json['playerUserMobile'] as String?,
      tournamentName: json['tournamentName'] as String?,
      tournamentDate: json['tournamentDate'] as String?,
      tournamentEndDate: json['tournamentEndDate'] as String?,
      tournamentImageFile: json['tournamentImageFile'] as String?,
      tournamentSportId: json['tournamentSportId'] as int?,
      tournamentSport: json['tournamentSport'] as String?,
      tournamentFeesAmount: (json['tournamentFeesAmount'] as num?)?.toDouble(),
      tournamentLocation: json['tournamentLocation'] as String?,
      tournamentCountry: json['tournamentCountry'] as String?,
      tournamentState: json['tournamentState'] as String?,
      tournamentDistrict: json['tournamentDistrict'] as String?,
      tournamentCity: json['tournamentCity'] as String?,
      tournamentRegion: json['tournamentRegion'] as String?,
      tournamentMaxRegistrations: json['tournamentMaxRegistrations'] as int?,
      teamId: json['teamId'] as int?,
      teamName: json['teamName'] as String?,
      registrationStatusId: json['registrationStatusId'] as int?,
      registrationStatus: json['registrationStatus'] as String?,
      paymentStatusId: json['paymentStatusId'] is int
          ? json['paymentStatusId'] as int
          : (json['paymentStatusId'] != null
              ? int.tryParse(json['paymentStatusId'].toString())
              : (json['paymentStatus'] is int
                  ? json['paymentStatus'] as int
                  : (json['paymentStatus'] != null
                      ? int.tryParse(json['paymentStatus'].toString())
                      : null))),
      paymentStatus: json['paymentStatus'] is String
          ? json['paymentStatus'] as String
          : (json['paymentStatus']?.toString()),
      paymentId: json['paymentId'] as String?,
      paymentDate: json['paymentDate'] as String?,
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble(),
      deletedTimestamp: json['deletedTimestamp'] as String?,
      deletedById: json['deletedById'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creationTimestamp': creationTimestamp,
      if (createdById != null) 'createdById': createdById,
      'playerUserId': playerUserId,
      'tournamentId': tournamentId,
      if (inviteCode != null) 'inviteCode': inviteCode,
      'deleted': deleted,
      'status': status,
      if (playerUserFirstName != null)
        'playerUserFirstName': playerUserFirstName,
      if (playerUserLastName != null) 'playerUserLastName': playerUserLastName,
      if (playerUserMobile != null) 'playerUserMobile': playerUserMobile,
      if (tournamentName != null) 'tournamentName': tournamentName,
      if (tournamentDate != null) 'tournamentDate': tournamentDate,
      if (tournamentEndDate != null) 'tournamentEndDate': tournamentEndDate,
      if (tournamentImageFile != null)
        'tournamentImageFile': tournamentImageFile,
      if (tournamentSportId != null) 'tournamentSportId': tournamentSportId,
      if (tournamentSport != null) 'tournamentSport': tournamentSport,
      if (tournamentFeesAmount != null)
        'tournamentFeesAmount': tournamentFeesAmount,
      if (tournamentLocation != null) 'tournamentLocation': tournamentLocation,
      if (tournamentCountry != null) 'tournamentCountry': tournamentCountry,
      if (tournamentState != null) 'tournamentState': tournamentState,
      if (tournamentDistrict != null) 'tournamentDistrict': tournamentDistrict,
      if (tournamentCity != null) 'tournamentCity': tournamentCity,
      if (tournamentRegion != null) 'tournamentRegion': tournamentRegion,
      if (tournamentMaxRegistrations != null)
        'tournamentMaxRegistrations': tournamentMaxRegistrations,
      if (teamId != null) 'teamId': teamId,
      if (teamName != null) 'teamName': teamName,
      if (registrationStatusId != null)
        'registrationStatusId': registrationStatusId,
      if (registrationStatus != null) 'registrationStatus': registrationStatus,
      if (paymentStatusId != null) 'paymentStatusId': paymentStatusId,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      if (paymentId != null) 'paymentId': paymentId,
      if (paymentDate != null) 'paymentDate': paymentDate,
      if (paymentAmount != null) 'paymentAmount': paymentAmount,
      if (deletedTimestamp != null) 'deletedTimestamp': deletedTimestamp,
      if (deletedById != null) 'deletedById': deletedById,
    };
  }
}
