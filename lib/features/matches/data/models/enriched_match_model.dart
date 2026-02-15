import 'match_model.dart';

class EnrichedMatchModel {
  final MatchModel match;
  final String team1Name;
  final String team2Name;

  EnrichedMatchModel({
    required this.match,
    required this.team1Name,
    required this.team2Name,
  });

  // Convenience getters to access match properties directly
  int get id => match.id;
  int get tournamentRoundId => match.tournamentRoundId;
  int get tournamentRoundGroupId => match.tournamentRoundGroupId;
  String get matchDatetime => match.matchDatetime;
  bool get deleted => match.deleted;
  bool get status => match.status;
  String get creationTimestamp => match.creationTimestamp;
  int get createdById => match.createdById;
  int get matchStatusId => match.matchStatusId;
  bool get teamSheetVerificationStatus => match.teamSheetVerificationStatus;
}
