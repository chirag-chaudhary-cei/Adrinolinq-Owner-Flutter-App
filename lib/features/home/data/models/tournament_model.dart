import 'package:flutter/foundation.dart';

/// Tournament model representing tournament data from API
class TournamentModel {
  const TournamentModel({
    required this.id,
    required this.creationTimestamp,
    required this.createdById,
    required this.createdByName,
    required this.createdByMobile,
    required this.communityId,
    required this.community,
    required this.name,
    required this.description,
    required this.country,
    required this.state,
    required this.district,
    required this.city,
    required this.region,
    required this.tournamentTypeId,
    required this.tournamentType,
    required this.tournamentDate,
    required this.tournamentEndDate,
    required this.rounds,
    required this.sportId,
    required this.sport,
    this.scoringTypeId,
    required this.feesAmount,
    required this.registrationStartDate,
    required this.registrationCloseDate,
    this.imageFile,
    required this.maximumRegistrationsCount,
    required this.isGlobalSearchable,
    required this.isPublished,
    required this.deleted,
    this.deletedTimestamp,
    this.deletedById,
    required this.status,
    this.rules,
    this.openOrClose = true,
    this.inviteCode,
    this.tournamentSponsorsList = const [],
    this.currentRegistered = 0,
    this.equipmentsRequired,
    this.playerAllocation = 0,
    this.tournamentRoundsList = const [],
  });

  final int id;
  final String creationTimestamp;
  final int createdById;
  final String createdByName;
  final String createdByMobile;
  final int communityId;
  final String community;
  final String name;
  final String description;
  final String country;
  final String state;
  final String district;
  final String city;
  final String region;
  final int tournamentTypeId;
  final String tournamentType;
  final String tournamentDate;
  final String tournamentEndDate;
  final int rounds;
  final int sportId;
  final String sport;
  final int? scoringTypeId;
  final double feesAmount;
  final String registrationStartDate;
  final String registrationCloseDate;
  final String? imageFile;
  final int maximumRegistrationsCount;
  final bool isGlobalSearchable;
  final bool isPublished;
  final bool deleted;
  final String? deletedTimestamp;
  final int? deletedById;
  final bool status;
  final String? rules;
  final bool openOrClose;
  final String? inviteCode;
  final List<Map<String, dynamic>> tournamentSponsorsList;
  final int currentRegistered;
  final String? equipmentsRequired;
  final int playerAllocation;
  final List<Map<String, dynamic>> tournamentRoundsList;

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    final sponsorsList = (json['tournamentSponsorsList'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    // Debug logging for sponsors
    if (kDebugMode) {
      print('🔍 [TournamentModel] fromJson for: ${json['name']}');
      final rawSponsors = json['tournamentSponsorsList'];
      print(
          '   📋 Raw tournamentSponsorsList type: ${rawSponsors?.runtimeType ?? "null"}');
      print(
          '   📊 Sponsors count in JSON: ${(rawSponsors as List<dynamic>?)?.length ?? 0}');
      print('   ✅ Parsed sponsors count: ${sponsorsList.length}');
      if (sponsorsList.isNotEmpty) {
        print('   🏆 First sponsor: ${sponsorsList.first}');
      }
    }

    return TournamentModel(
      id: json['id'] as int,
      creationTimestamp: json['creationTimestamp'] as String? ?? '',
      createdById: (json['createdById'] ?? 0) as int,
      createdByName: json['createdByName'] as String? ?? '',
      createdByMobile: json['createdByMobile'] as String? ?? '',
      communityId: json['communityId'] as int,
      community: json['community'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      country: json['country'] as String? ?? '',
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      city: json['city'] as String? ?? '',
      region: json['region'] as String? ?? '',
      tournamentTypeId: json['tournamentTypeId'] as int,
      tournamentType: json['tournamentType'] as String? ?? '',
      tournamentDate: json['tournamentDate'] as String? ?? '',
      tournamentEndDate: json['tournamentEndDate'] as String? ?? '',
      rounds: (json['rounds'] ?? 0) as int,
      sportId: json['sportId'] as int,
      sport: json['sport'] as String? ?? '',
      scoringTypeId: json['scoringTypeId'] as int?,
      feesAmount: ((json['feesAmount'] ?? 0) as num).toDouble(),
      registrationStartDate: json['registrationStartDate'] as String? ?? '',
      registrationCloseDate: json['registrationCloseDate'] as String? ?? '',
      imageFile: json['imageFile'] as String?,
      maximumRegistrationsCount:
          (json['maximumRegistrationsCount'] ?? 0) as int,
      isGlobalSearchable: json['isGlobalSearchable'] as bool? ?? false,
      isPublished: json['isPublished'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      deletedTimestamp: json['deletedTimestamp'] as String?,
      deletedById: json['deletedById'] as int?,
      status: json['status'] as bool? ?? false,
      rules: json['rules'] as String?,
      openOrClose: (json['openOrClose'] == true)
          ? true
          : (json['openOrClose'] == false ? false : true),
      inviteCode: json['inviteCode'] as String?,
      tournamentSponsorsList: sponsorsList,
      currentRegistered: json['currentRegistered'] as int? ?? 0,
      equipmentsRequired: json['equipmentsRequired'] as String?,
      playerAllocation: json['playerAllocation'] as int? ?? 0,
      tournamentRoundsList: (json['tournamentRoundsList'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    final jsonMap = {
      'id': id,
      'creationTimestamp': creationTimestamp,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdByMobile': createdByMobile,
      'communityId': communityId,
      'community': community,
      'name': name,
      'description': description,
      'country': country,
      'state': state,
      'district': district,
      'city': city,
      'region': region,
      'tournamentTypeId': tournamentTypeId,
      'tournamentType': tournamentType,
      'tournamentDate': tournamentDate,
      'tournamentEndDate': tournamentEndDate,
      'rounds': rounds,
      'sportId': sportId,
      'sport': sport,
      'scoringTypeId': scoringTypeId,
      'feesAmount': feesAmount,
      'registrationStartDate': registrationStartDate,
      'registrationCloseDate': registrationCloseDate,
      'imageFile': imageFile,
      'maximumRegistrationsCount': maximumRegistrationsCount,
      'isGlobalSearchable': isGlobalSearchable,
      'isPublished': isPublished,
      'deleted': deleted,
      'deletedTimestamp': deletedTimestamp,
      'deletedById': deletedById,
      'status': status,
      'rules': rules,
      'openOrClose': openOrClose,
      'inviteCode': inviteCode,
      'tournamentSponsorsList': tournamentSponsorsList,
      'currentRegistered': currentRegistered,
      'equipmentsRequired': equipmentsRequired,
      'playerAllocation': playerAllocation,
      'tournamentRoundsList': tournamentRoundsList,
    };

    if (kDebugMode) {
      print('📤 [TournamentModel] toJson for: $name');
      print('   🏆 Sponsors in model: ${tournamentSponsorsList.length}');
      print(
          '   📋 Sponsors in JSON output: ${jsonMap['tournamentSponsorsList']}');
    }

    return jsonMap;
  }
}
