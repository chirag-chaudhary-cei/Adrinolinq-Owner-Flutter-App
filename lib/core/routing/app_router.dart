import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/splash_screen_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_personal_info_page.dart';
import '../../features/auth/presentation/pages/register_password_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/navigation/main_shell.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/payment/presentation/pages/payment_status_page.dart';
import '../../features/my_tournament/presentation/pages/registered_tournament_detail_page.dart';
import '../../features/my_tournament/presentation/pages/match_details_page.dart';
import '../../features/my_tournament/presentation/pages/live_match_screen.dart';
import '../../features/my_tournament/data/models/tournament_registration_model.dart';
import '../../features/my_tournament/presentation/pages/player_profile_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/tournament_detail_page.dart';
import '../../features/home/data/models/tournament_model.dart';
import '../../core/widgets/event_card.dart';
import 'route_guard.dart';

class AppRouter {
  static const splash = '/';
  static const welcome = '/welcome';
  static const onboardingIntro = '/onboarding-intro';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const registerPassword = '/register/password';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const sportsPreferences = '/profile/sports-preferences';
  static const changePassword = '/profile/change-password';
  static const selectSports = '/profile/select-sports';
  static const eventDetail = '/event-detail';
  static const tournamentDetail = '/tournament-detail';
  static const paymentStatus = '/payment-status';
  static const registeredTournamentDetail = '/registered-tournament-detail';
  static const matchDetails = '/match-details';
  static const liveMatchScreen = '/live-match-screen';
  static const playerProfile = '/player-profile';

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreenPage());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case onboardingIntro:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case home:
        return MaterialPageRoute(builder: (_) => const MainShell());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPersonalInfoPage(),
        );
      case registerPassword:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => RegisterPasswordPage(
            firstName: args['firstName'] ?? '',
            lastName: args['lastName'] ?? '',
            email: args['email'] ?? '',
            mobile: args['mobile'] ?? '',
          ),
        );
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
        );
      case onboarding:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            firstName: args['firstName'] ?? '',
            lastName: args['lastName'] ?? '',
            email: args['email'] ?? '',
            mobile: args['mobile'] ?? '',
          ),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(showBackButton: true),
        );
      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(
            isEditMode: true,
          ),
        );
      case sportsPreferences:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());
      case tournamentDetail:
        // Accept either a raw int ID or a full TournamentModel (from home tap)
        final detailArg = settings.arguments;
        final tournamentId =
            detailArg is TournamentModel ? detailArg.id : detailArg as int;
        return MaterialPageRoute(
          builder: (_) => TournamentDetailPage(tournamentId: tournamentId),
        );
      case paymentStatus:
        if (settings.arguments is PaymentStatus) {
          final status = settings.arguments as PaymentStatus;
          return MaterialPageRoute(
            builder: (_) => PaymentStatusPage(status: status),
          );
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => PaymentStatusPage(
              status: args['status'] as PaymentStatus,
              event: args['event'] as EventModel?,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const PaymentStatusPage(),
        );
      case registeredTournamentDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final event = args['event'] as EventModel;
        // Accept either a TournamentRegistrationModel directly (from my_tournament_page)
        // or a TournamentModel (from home_content tap — same as Player app)
        final TournamentRegistrationModel registration;
        if (args['registration'] is TournamentRegistrationModel) {
          registration = args['registration'] as TournamentRegistrationModel;
        } else {
          final tournament = args['tournament'] as TournamentModel;
          registration = TournamentRegistrationModel(
            id: tournament.id,
            creationTimestamp:
                tournament.creationTimestamp ?? DateTime.now().toString(),
            playerUserId: 0,
            tournamentId: tournament.id,
            deleted: false,
            status: true,
            tournamentName: tournament.name,
            tournamentDate: tournament.tournamentDate,
            tournamentEndDate: tournament.tournamentEndDate,
            tournamentImageFile: tournament.imageFile,
            tournamentSportId: tournament.sportId,
            tournamentSport: tournament.sport,
            tournamentFeesAmount: tournament.feesAmount.toDouble(),
            tournamentCountry: tournament.country,
            tournamentState: tournament.state,
            tournamentDistrict: tournament.district,
            tournamentCity: tournament.city,
            tournamentMaxRegistrations: tournament.maximumRegistrationsCount,
            registrationStatus: 'Registered',
            paymentStatus: 'Paid',
          );
        }
        return MaterialPageRoute(
          builder: (_) => RegisteredTournamentDetailPage(
            event: event,
            registration: registration,
          ),
        );
      case matchDetails:
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (_) => MatchDetailsPage(event: event),
        );
      case liveMatchScreen:
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (_) => LiveMatchScreen(event: event),
        );
      case playerProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PlayerProfileScreen(
            player: args['player'] as PlayerModel,
            isOwnProfile: args['isOwnProfile'] as bool? ?? false,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }

  Route<dynamic> guarded({
    required RouteSettings settings,
    required RouteGuard guard,
    required WidgetBuilder builder,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        if (!guard.canActivate(settings)) {
          return guard.fallback(context: context);
        }
        return builder(context);
      },
    );
  }
}
