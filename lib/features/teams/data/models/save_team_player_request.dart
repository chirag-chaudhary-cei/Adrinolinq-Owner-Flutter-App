/// Request model for saving team players
class SaveTeamPlayerRequest {
  const SaveTeamPlayerRequest({
    required this.teamId,
    required this.sportRoleId,
    this.mobile,
    this.email,
  });

  final int teamId;
  final int sportRoleId;
  final String? mobile;
  final String? email;

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'sportRoleId': sportRoleId,
      if (mobile != null && mobile!.isNotEmpty) 'mobile': mobile,
      if (email != null && email!.isNotEmpty) 'email': email,
    };
  }
}
