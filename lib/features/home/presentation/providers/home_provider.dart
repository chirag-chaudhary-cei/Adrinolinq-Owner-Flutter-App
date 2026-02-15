import 'package:flutter/foundation.dart';
import '../../../../core/widgets/event_card.dart';
import '../../../../core/widgets/user_header.dart';

// API imports to fetch real profile
import '../../../../core/config/app_config.dart';
import '../../../../core/api/api_client.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';
import '../../../profile/data/repositories/profile_repository.dart';

/// Home screen provider with state management
class HomeProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // User profile (start as guest until loaded from API)
  UserProfile _currentUser = const UserProfile(
    id: '',
    name: 'Guest',
    avatarUrl: null,
    weatherLabel: null,
    weatherIcon: null,
  );

  // Event lists
  List<EventModel> _recentlyViewedEvents = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _popularEvents = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  UserProfile get currentUser => _currentUser;
  List<EventModel> get recentlyViewedEvents => _recentlyViewedEvents;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get popularEvents => _popularEvents;

  HomeProvider() {
    _loadDummyData();
    _loadProfileFromApi();
  }

  /// Force reload profile from API (public)
  Future<void> reloadProfile() async {
    await _loadProfileFromApi();
  }

  /// Load profile from API and update current user
  Future<void> _loadProfileFromApi() async {
    try {
      final config = AppConfig.load();
      final apiClient = ApiClient(config);
      final remote = ProfileRemoteDataSource(apiClient);
      final repository = ProfileRepository(remoteDataSource: remote);

      // Try to get cached profile first for instant display
      final cachedProfile = remote.getCachedProfile();
      if (cachedProfile != null) {
        _updateUserProfile(cachedProfile, repository);
      }

      // Then fetch fresh data from API
      final profile = await repository.getProfile();
      _updateUserProfile(profile, repository);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load profile for home header: $e');
      }
    }
  }

  /// Helper to update user profile from profile model
  void _updateUserProfile(dynamic profile, ProfileRepository repository) {
    final fullName = '${profile.firstName ?? ''}'.trim() +
        (profile.lastName != null && profile.lastName!.isNotEmpty
            ? ' ${profile.lastName!}'
            : '');

    final avatarUrl = repository.getUserImageUrl(profile.imageFile);

    if (kDebugMode) {
      print('🖼️ [HomeProvider] Profile imageFile: ${profile.imageFile}');
      print('🖼️ [HomeProvider] Constructed avatarUrl: $avatarUrl');
    }

    _currentUser = UserProfile(
      id: profile.id,
      name: fullName.isNotEmpty ? fullName : 'Guest User',
      avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
      weatherLabel: null,
      weatherIcon: null,
    );
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void _loadDummyData() {
    _recentlyViewedEvents = [
      const EventModel(
        id: '1',
        title: 'Elite Badminton Championship',
        location: 'Downtown Sports Arena',
        imageUrl: 'assets/images/demo1.jpg',
        date: '15-Dec-2024',
        time: '09:00 AM',
        price: '150',
        category: 'Football',
        tags: ['Racket', 'Shuttlecock'],
        registeredCount: 16,
        maxParticipants: 16,
        isLive: false,
      ),
      const EventModel(
        id: '2',
        title: 'Elite Badminton Championship',
        location: 'Downtown Sports Arena',
        imageUrl: 'assets/images/demo2.jpg',
        date: '15-Dec-2024',
        time: '09:00 AM',
        price: '150',
        category: 'Badminton',
        tags: ['Racket', 'Shuttlecock'],
        registeredCount: 16,
        maxParticipants: 16,
        isLive: true,
      ),
      const EventModel(
        id: '3',
        title: 'Elite Badminton Championship',
        location: 'Downtown Sports Arena',
        imageUrl: 'assets/images/demo1.jpg',
        date: '15-Dec-2024',
        time: '09:00 AM',
        price: '150',
        category: 'Football',
        tags: ['Racket', 'Shuttlecock'],
        registeredCount: 16,
        maxParticipants: 16,
        isLive: false,
      ),
      const EventModel(
        id: '4',
        title: 'Elite Badminton Championship',
        location: 'Downtown Sports Arena',
        imageUrl: 'assets/images/demo2.jpg',
        date: '15-Dec-2024',
        time: '09:00 AM',
        price: '150',
        category: 'Badminton',
        tags: ['Racket', 'Shuttlecock'],
        registeredCount: 16,
        maxParticipants: 16,
        isLive: true,
      ),
    ];

    _upcomingEvents = [];

    _popularEvents = [
      const EventModel(
        id: '6',
        title: 'Yoga & Wellness Retreat',
        location: 'Harmony Studio',
        imageUrl:
            'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600&h=400&fit=crop',
        date: '28-Dec-2024',
        time: '07:00 AM',
        price: '80',
        category: 'Yoga',
        tags: ['Meditation', 'Wellness'],
        registeredCount: 28,
        maxParticipants: 30,
      ),
      const EventModel(
        id: '7',
        title: 'Football Tournament',
        location: 'Stadium Arena',
        imageUrl:
            'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=600&h=400&fit=crop',
        date: '02-Jan-2025',
        time: '04:00 PM',
        price: '75',
        category: 'Football',
        tags: ['11v11', 'League'],
        registeredCount: 40,
        maxParticipants: 44,
      ),
    ];
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _loadDummyData();
      _loadProfileFromApi();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }
}
