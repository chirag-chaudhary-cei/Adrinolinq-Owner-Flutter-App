import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors_new.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../matches/presentation/pages/matches_page.dart';
import '../home/presentation/providers/home_provider.dart';
import '../home/presentation/widgets/home_content.dart';
import '../my_tournament/presentation/pages/my_tournament_page.dart';
import '../profile/presentation/pages/profile_page.dart';
import '../teams/presentation/pages/teams_page.dart';

/// Main Shell - Contains the bottom navigation and all tab pages
/// Uses IndexedStack to preserve state when switching tabs
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeTab(onNavigateToTab: _onTabTapped),
      const MyTournamentPage(),
      const TeamsPage(),
      const MatchesPage(),
      const ProfilePage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

/// Home Tab wrapper with Provider
class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.onNavigateToTab});

  final ValueChanged<int> onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: HomeContent(onNavigateToProfile: () => onNavigateToTab(4)),
        ),
      ),
    );
  }
}
