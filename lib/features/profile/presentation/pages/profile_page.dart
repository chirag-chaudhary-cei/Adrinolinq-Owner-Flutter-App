import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/cache/hive_cache_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/profile_model.dart';
import '../providers/profile_providers.dart';

/// Profile Page - Modern UI with gradient header and menu items
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    super.key,
    this.showBackButton = false,
  });

  /// Whether to show back button in header
  /// Set to false when used in bottom tab navigation
  final bool showBackButton;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with WidgetsBindingObserver {
  UserProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _checkAndReloadProfile();
    }
  }

  Future<void> _checkAndReloadProfile() async {
    final profileDataSource = ref.read(profileRemoteDataSourceProvider);
    final hasCachedProfile = profileDataSource.hasCachedProfile();

    if (!hasCachedProfile && mounted) {
      await _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final profileDataSource = ref.read(profileRemoteDataSourceProvider);

      // Try to get cached profile first for instant display
      final cachedProfile = profileDataSource.getCachedProfile();
      if (cachedProfile != null && mounted) {
        setState(() {
          _profile = cachedProfile;
          _isLoading = false;
        });
      }

      // Then fetch fresh data from API
      final profile = await profileRepo.getProfile();

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    if (phone.length >= 10) {
      return '+91 ${phone.substring(0, 2)}XXX XXX${phone.substring(phone.length - 2)}';
    }
    return phone;
  }

  Future<void> _logout() async {
    final confirmed = await AppDialogs.showConfirmation(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      customGifPath: 'assets/gifs/deleteAlert.gif',
    );

    if (confirmed != true) return;

    try {
      // Clear all Hive caches
      await HiveCacheManager.instance.clearAll();

      // Clear token
      await SecureStorage.instance.delete('auth_token');

      // Clear flags
      final localStorage = LocalStorage.instance;
      await localStorage.setBool(AppConstants.keyIsLoggedIn, false);
      await localStorage.setBool(AppConstants.keyProfileSaved, false);
      await localStorage.setBool(
        AppConstants.keyRegistrationOnboardingPending,
        false,
      );

      // Clear user data
      await localStorage.remove('user_email');
      await localStorage.remove('user_id');
      await localStorage.remove('user_first_name');
      await localStorage.remove('user_last_name');
      await localStorage.remove('user_mobile');

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.login,
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        AppDialogs.showError(context, message: 'Failed to logout');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: _isLoading
            ? AppLoading.page(
                message: 'Loading profile...',
                backgroundColor: const Color(0xFFF8F8F8),
              )
            : _errorMessage != null
                ? _buildErrorView(context)
                : _buildContent(context),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppResponsive.padding(context, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppResponsive.icon(context, 64),
              color: Colors.grey.shade400,
            ),
            SizedBox(height: AppResponsive.s(context, 16)),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppResponsive.font(context, 16),
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: AppResponsive.s(context, 24)),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: AppResponsive.s(context, 20)),
          _buildProfileHeader(context),
          SizedBox(height: AppResponsive.s(context, 20)),
          Padding(
            padding: AppResponsive.paddingSymmetric(context, horizontal: 20),
            child: Column(
              children: [
                _ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRouter.editProfile,
                    );
                    if (result == true && mounted) {
                      _loadProfile();
                    }
                  },
                ),
                // SizedBox(height: AppResponsive.s(context, 12)),
                // _ProfileMenuItem(
                //   icon: Icons.settings_outlined,
                //   title: 'Sports Preferences',
                //   onTap: () async {
                //     final result = await Navigator.pushNamed(
                //       context,
                //       AppRouter.sportsPreferences,
                //     );
                //     if (result == true && mounted) {
                //       _loadProfile();
                //     }
                //   },
                // ),
                SizedBox(height: AppResponsive.s(context, 12)),
                _ProfileMenuItem(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () {},
                ),
                SizedBox(height: AppResponsive.s(context, 12)),
                _ProfileMenuItem(
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Us',
                  onTap: () {},
                ),
                SizedBox(height: AppResponsive.s(context, 12)),
                _ProfileMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {},
                ),
                SizedBox(height: AppResponsive.s(context, 12)),
                _ProfileMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                SizedBox(height: AppResponsive.s(context, 12)),
                _ProfileMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.changePassword);
                  },
                ),
                SizedBox(height: AppResponsive.s(context, 12)),
                _ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: _logout,
                ),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.s(context, 80)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final name =
        '${_profile?.firstName ?? ''} ${_profile?.lastName ?? ''}'.trim();
    final email = _profile?.email ?? '';
    final phone = _formatPhoneNumber(_profile?.mobile);
    final imageFile = _profile?.imageFile;
    final hasImage = imageFile != null && imageFile.isNotEmpty;

    return Padding(
      padding: AppResponsive.paddingSymmetric(context, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF90D5FF),
              Color(0xFF0000FF),
              Color(0xFF040273),
            ],
          ),
          borderRadius: AppResponsive.borderRadius(context, 32),
        ),
        child: Padding(
          padding: AppResponsive.padding(
            context,
            horizontal: 24,
            vertical: 20,
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: AppResponsive.s(context, 72),
                    height: AppResponsive.s(context, 72),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: ref
                                  .read(profileRepositoryProvider)
                                  .getUserImageUrl(imageFile),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: AppLoading.circularWhite(
                                    size: 24.0,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/defaultProfile.png',
                                fit: BoxFit.fitHeight,
                              ),
                            )
                          : Image.asset(
                              'assets/images/defaultProfile.png',
                              fit: BoxFit.fitHeight,
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppResponsive.s(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'User Name',
                      style: TextStyle(
                        fontSize: AppResponsive.font(context, 20),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppResponsive.s(context, 2)),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: AppResponsive.font(context, 13),
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      SizedBox(height: AppResponsive.s(context, 2)),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: AppResponsive.font(context, 13),
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable Profile Menu Item Widget
class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? const Color(0xFFFF3B30) : const Color(0xFF1A1A1A);
    final iconColor =
        isDestructive ? const Color(0xFFFF3B30) : const Color(0xFF000000);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppResponsive.padding(context, horizontal: 11, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppResponsive.borderRadius(context, 46),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: AppResponsive.s(context, 48),
              height: AppResponsive.s(context, 48),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: AppResponsive.borderRadius(context, 46),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: AppResponsive.icon(context, 26),
                  color: iconColor,
                ),
              ),
            ),
            SizedBox(width: AppResponsive.s(context, 10)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppResponsive.font(context, 16),
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: AppResponsive.icon(context, 34),
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
