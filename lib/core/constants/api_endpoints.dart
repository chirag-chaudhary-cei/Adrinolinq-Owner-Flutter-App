/// API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/api/Users/login';
  static const String register = '/api/Users/registerOwnerUser';
  static const String registerOTP = '/api/Users/registerOTP';

  // Forgot Password
  static const String forgotGenerateOTP = '/api/Users/generateForgetOTP';
  static const String forgotVerifyOTP = '/api/Users/verifyForgetOTP';
  static const String forgotPassword = '/api/Users/forgetPassword';

  // Change Password
  static const String changePassword = '/api/Users/changePassword';

  // User
  static const String getProfile = '/api/Users/getProfile';
  static const String updateProfile = '/api/Users/updateProfile';
  static const String saveUsers = '/api/Users/saveUsers';
  static const String profile = '/user/profile';

  // TypeData - Get dropdown lists by typeMasterId
  static const String getTypeDataList = '/api/TypeData/getTypeDataList';

  // Community
  static const String getCommunityList = '/api/Community/getCommunityList';

  // Location - Cascading dropdowns
  static const String getCountryList = '/api/Country/getCountryList';
  static const String getStateList = '/api/State/getStateList';
  static const String getDistrictList = '/api/District/getDistrictList';
  static const String getCityList = '/api/City/getCityList';
  static const String getRegionList = '/api/Region/getRegionList';

  // Sports
  static const String getSportsList = '/api/Sports/getSportsList';
  static const String savePlayerSportsPreferences =
      '/api/PlayerSportsPreferences/savePlayerSportsPreferences';

  // Tournaments
  static const String getTournamentsList =
      '/api/Tournaments/getTournamentsList';

  // Tournament Registrations
  static const String getTournamentRegistrationsList =
      '/api/TournamentRegistrations/getTournamentRegistrationsList';
  static const String saveTournamentRegistrations =
      '/api/TournamentRegistrations/saveTournamentRegistrations';

  // Teams
  static const String getTeamsList = '/api/Teams/getTeamsList';
  static const String saveTeams = '/api/Teams/saveTeams';
  static const String deleteTeams = '/api/Teams/deleteTeams';

  // Team Players
  static const String getTeamPlayersList =
      '/api/TeamPlayers/getTeamPlayersList';
  static const String saveTeamPlayers = '/api/TeamPlayers/saveTeamPlayers';

  // File Upload
  static const String uploadUserFile = '/api/FileUpload/UploadUserFile';
  static const String UploadTeamsFile = '/api/FileUpload/UploadTeamsFile';

  // Uploads (File Download - base paths, append filename)
  static const String tournamentsUploads = '/Uploads/Tournaments/';
  static const String usersUploads = '/Uploads/Users/';
  static const String sportsUploads = '/Uploads/Sports/';
  static const String teamUploads = '/Uploads/Teams/';

  // Tournament Teams
  static const String getTournamentTeamsList =
      '/api/TournamentTeams/getTournamentTeamsList';
  static const String saveTournamentTeams =
      '/api/TournamentTeams/saveTournamentTeams';

  // Tournament Team Players
  static const String getTournamentTeamPlayersList =
      '/api/TournamentTeamPlayers/getTournamentTeamPlayersList';
  static const String saveTournamentTeamPlayers =
      '/api/TournamentTeamPlayers/saveTournamentTeamPlayers';
  static const String deleteTournamentTeamPlayers =
      '/api/TournamentTeamPlayers/deleteTournamentTeamPlayers';

  // Sport Roles
  static const String getSportRolesList = '/api/SportRoles/getSportRolesList';

  // User Search
  static const String getUsersList = '/api/Users/getUsersList';

  // Tournament Sponsors
  static const String getTournamentSponsorsList =
      '/api/TournamentSponsors/getTournamentSponsorsList';
  static const String sponsorUploads = '/Uploads/Tournament Sponsors/';

  // Tournament Round Matches
  static const String getTournamentRoundMatchesList =
      '/api/TournamentRoundMatches/getTournamentRoundMatchesList';

  // Tournament Round Group Teams
  static const String getTournamentRoundGroupTeamsList =
      '/api/TournamentRoundGroupTeams/getTournamentRoundGroupTeamsList';
}
