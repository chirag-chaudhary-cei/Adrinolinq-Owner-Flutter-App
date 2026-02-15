import 'package:adrinolinq_owner/core/utils/app_assets.dart';
import 'package:adrinolinq_owner/core/utils/image_crop_config.dart';
import 'package:adrinolinq_owner/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/models/type_data_model.dart';
import '../../data/models/location_models.dart';
import '../../data/models/save_user_request.dart';
import '../providers/onboarding_providers.dart';

/// Onboarding Screen - 2 Phase wizard UI
/// Phase 0: Basic (Name Title, First Name, Last Name, DOB, Mobile No., Email ID)
/// Phase 1: Address (Street, Pincode, Country, State, District, City, Region)
///
/// Can also be used for editing profile by setting [isEditMode] to true
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.isEditMode = false,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobile;

  /// When true, shows "Edit Profile" header and adjusts navigation/save behavior
  final bool isEditMode;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // Current phase (0-1)
  int _currentPhase = 0;
  // Only two phases: Basic and Address
  int get _totalPhases => 2;

  // Profile Image
  File? _profileImage;
  String? _uploadedImageFileName; // Store uploaded image filename from API
  bool _isUploadingImage = false; // Track if image upload is in progress

  // Phase 0: Basic Details Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  final TextEditingController _dobController = TextEditingController();
  TypeDataItem? _selectedNameTitle;
  DateTime? _selectedDob;

  // Phase 1: Address
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  DistrictModel? _selectedDistrict;
  CityModel? _selectedCity;

  // Track if profile data has been loaded (for cascade timing)
  bool _profileLoaded = false;

  // Loading states
  bool _isLoading = false;
  bool _isLoadingInitialData = true; // Track initial profile data load

  // Change tracking - Store initial values to detect changes
  Map<String, dynamic> _initialProfileData = {};

  // Location lists (populated from API)
  List<StateModel> _states = [];
  List<DistrictModel> _districts = [];
  List<CityModel> _cities = [];
  // List<RegionModel> _regions = []; // Removed
  // List<CommunityModel> _communities = []; // Removed

  // Loading states for location dropdowns
  bool _isLoadingStates = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingCities = false;
  // bool _isLoadingRegions = false; // Removed
  // bool _isLoadingCommunities = false; // Removed

  // Preloaded IDs from existing profile (to match when dropdown data loads)
  int? _preloadedNameTitleId;
  int? _preloadedCountryId;
  int? _preloadedStateId;
  int? _preloadedDistrictId;
  int? _preloadedCityId;

  @override
  void initState() {
    super.initState();
    // Initialize controllers - will be filled from API
    _firstNameController = TextEditingController(text: widget.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.lastName ?? '');
    _emailController = TextEditingController(text: widget.email ?? '');
    _mobileController = TextEditingController(text: widget.mobile ?? '');

    // Load existing profile data (if any) to prefill form
    // This will also load communities appropriately based on edit mode
    _loadExistingProfile();
  }

  /// Parse backend DOB strings into [DateTime]. Supports common formats:
  /// - ISO (YYYY-MM-DD or with time)
  /// - DD-MM-YYYY (with optional time)
  /// Returns null if parsing fails.
  DateTime? _parseBackendDate(String raw) {
    final s = raw.trim();

    // If it's already ISO-like, try DateTime.tryParse first
    try {
      final tryIso = DateTime.tryParse(s);
      if (tryIso != null) return tryIso;
    } catch (_) {}

    // Strip time part if present (space or T)
    final dateOnly = s.split(' ').first.split('T').first;

    // Try ISO date-only (YYYY-MM-DD)
    final isoMatch = RegExp(r'^\d{4}-\d{2}-\d{2}\$');
    if (isoMatch.hasMatch(dateOnly)) {
      try {
        return DateTime.parse(dateOnly);
      } catch (_) {}
    }

    // Try DD-MM-YYYY (common backend format like 08-01-2026)
    final dmyMatch = RegExp(r'^(\d{2})-(\d{2})-(\d{4})\z');
    final dmy = dmyMatch.firstMatch(dateOnly);
    if (dmy != null) {
      try {
        final day = int.parse(dmy.group(1)!);
        final month = int.parse(dmy.group(2)!);
        final year = int.parse(dmy.group(3)!);
        return DateTime(year, month, day);
      } catch (_) {}
    }

    // As a last resort, try parsing with DateTime.tryParse on the cleaned string
    try {
      return DateTime.tryParse(dateOnly);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _streetController.dispose();
    _pincodeController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  /// Load states with automatic chaining to districts, cities, and regions
  /// This ensures the entire location hierarchy is loaded sequentially
  Future<void> _loadStatesWithChain(int countryId) async {
    print(
      '🔄 [Cascade] Loading states for countryId=$countryId (preloadedStateId=$_preloadedStateId)',
    );

    setState(() {
      _isLoadingStates = true;
      _states = [];
      // Don't clear _selectedState here - we'll set it after loading
    });

    try {
      final repository = ref.read(onboardingRepositoryProvider);
      final states = await repository.getStates(countryId);

      if (!mounted) return;

      print('✅ [Cascade] States loaded: ${states.length} items');

      setState(() {
        _states = states;
        _isLoadingStates = false;
      });

      // Match preloaded state ID
      if (_preloadedStateId != null && states.isNotEmpty) {
        print(
          '🔍 [Cascade] Looking for stateId=$_preloadedStateId in ${states.length} states',
        );
        try {
          final match =
              states.firstWhere((item) => item.id == _preloadedStateId);

          print(
            '✅ [Cascade] State matched: ID=${match.id}, Name=${match.name}',
          );

          setState(() {
            _selectedState = match;
          });

          // Clear preloaded ID after matching
          final districtIdToLoad = _preloadedDistrictId;
          _preloadedStateId = null;

          // Chain: Load districts if district ID is preloaded
          if (districtIdToLoad != null) {
            print(
              '🔄 [Cascade] Continuing chain: Loading districts for stateId=${match.id}',
            );
            await _loadDistrictsWithChain(match.id);
          } else {
            print('ℹ️ [Cascade] No preloaded districtId, chain ends here');
          }

          // Also load cities based on state ID
          final cityIdToLoad = _preloadedCityId;
          if (cityIdToLoad != null) {
            print('🔄 [Cascade] Loading cities for stateId=${match.id}');
            await _loadCitiesWithChain(match.id);
          }
        } catch (e) {
          print('⚠️ [Cascade] State not found for ID=$_preloadedStateId');
          _preloadedStateId = null;
        }
      } else {
        print('ℹ️ [Cascade] No preloaded stateId or empty states list');
      }
    } catch (e) {
      print('❌ [Cascade] Error loading states: $e');
      if (mounted) {
        setState(() => _isLoadingStates = false);
      }
    }
  }

  /// Load districts with automatic chaining to cities and regions
  Future<void> _loadDistrictsWithChain(int stateId) async {
    print(
      '🔄 [Cascade] Loading districts for stateId=$stateId (preloadedDistrictId=$_preloadedDistrictId)',
    );

    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
    });

    try {
      final repository = ref.read(onboardingRepositoryProvider);
      final districts = await repository.getDistricts(stateId);

      if (!mounted) return;

      print('✅ [Cascade] Districts loaded: ${districts.length} items');

      setState(() {
        _districts = districts.reversed.toList(); // Reverse district list
        _isLoadingDistricts = false;
      });

      // Match preloaded district ID
      if (_preloadedDistrictId != null && districts.isNotEmpty) {
        print(
          '🔍 [Cascade] Looking for districtId=$_preloadedDistrictId in ${districts.length} districts',
        );
        try {
          final match =
              districts.firstWhere((item) => item.id == _preloadedDistrictId);

          print(
            '✅ [Cascade] District matched: ID=${match.id}, Name=${match.name}',
          );

          setState(() {
            _selectedDistrict = match;
          });

          // Clear preloaded ID after matching
          _preloadedDistrictId = null;

          // Don't chain to cities from districts - cities are loaded by state
          print(
            'ℹ️ [Cascade] Districts loaded, cities should be loaded by state',
          );
        } catch (e) {
          print('⚠️ [Cascade] District not found for ID=$_preloadedDistrictId');
          _preloadedDistrictId = null;
        }
      } else {
        print('ℹ️ [Cascade] No preloaded districtId or empty districts list');
      }
    } catch (e) {
      print('❌ [Cascade] Error loading districts: $e');
      if (mounted) {
        setState(() => _isLoadingDistricts = false);
      }
    }
  }

  /// Load cities with automatic chaining to regions
  Future<void> _loadCitiesWithChain(int stateId) async {
    print(
      '🔄 [Cascade] Loading cities for stateId=$stateId (preloadedCityId=$_preloadedCityId)',
    );

    setState(() {
      _isLoadingCities = true;
      _cities = [];
    });

    try {
      final repository = ref.read(onboardingRepositoryProvider);
      final cities = await repository.getCities(stateId);

      if (!mounted) return;

      print('✅ [Cascade] Cities loaded: ${cities.length} items');

      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });

      // Match preloaded city ID
      if (_preloadedCityId != null && cities.isNotEmpty) {
        print(
          '🔍 [Cascade] Looking for cityId=$_preloadedCityId in ${cities.length} cities',
        );
        try {
          final match =
              cities.firstWhere((item) => item.id == _preloadedCityId);

          print('✅ [Cascade] City matched: ID=${match.id}, Name=${match.name}');
          print('🎉 [Cascade] Location cascade complete!');

          setState(() {
            _selectedCity = match;
          });
          _preloadedCityId = null;
        } catch (e) {
          print('⚠️ [Cascade] City not found for ID=$_preloadedCityId');
          _preloadedCityId = null;
        }
      } else {
        print('ℹ️ [Cascade] No preloaded cityId or empty cities list');
      }
    } catch (e) {
      print('❌ [Cascade] Error loading cities: $e');
      if (mounted) {
        setState(() => _isLoadingCities = false);
      }
    }
  }

  /*
  /// Load regions (final step in chain)
  Future<void> _loadRegionsWithChain(int cityId) async {
     // ... method removed ...
  }
  */

  // Load states by country
  Future<void> _loadStates(int countryId) async {
    setState(() {
      _isLoadingStates = true;
      _states = [];
      _selectedState = null;
      _districts = [];
      _selectedDistrict = null;
      _cities = [];
      _selectedCity = null;
      _cities = [];
      _selectedCity = null;
    });

    try {
      final repository = ref.read(onboardingRepositoryProvider);
      final states = await repository.getStates(countryId);
      if (mounted) {
        setState(() {
          _states = states;
          _isLoadingStates = false;
        });

        // Match preloaded state ID
        if (_preloadedStateId != null && states.isNotEmpty) {
          try {
            final match =
                states.firstWhere((item) => item.id == _preloadedStateId);
            setState(() {
              _selectedState = match;
              _preloadedStateId = null; // Clear after matching
            });
            // Load districts if district ID is preloaded
            if (_preloadedDistrictId != null) {
              _loadDistricts(match.id);
            }
          } catch (_) {
            _preloadedStateId = null; // Clear even if not found
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStates = false);
      }
    }
  }

  // Load districts by state
  Future<void> _loadDistricts(int stateId) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
      _cities = [];
      _selectedCity = null;
      // _regions = []; // Removed
      // _selectedRegion = null; // Removed
    });

    try {
      final repository = ref.read(onboardingRepositoryProvider);
      final districts = await repository.getDistricts(stateId);

      if (mounted) {
        setState(() {
          _districts = districts.reversed.toList(); // Reverse district list
          _isLoadingDistricts = false;
        });

        // Match preloaded district ID
        if (_preloadedDistrictId != null && districts.isNotEmpty) {
          try {
            final match =
                districts.firstWhere((item) => item.id == _preloadedDistrictId);
            setState(() {
              _selectedDistrict = match;
              _preloadedDistrictId = null; // Clear after matching
            });
            // Load cities if city ID is preloaded
            if (_preloadedCityId != null) {
              _loadCities(match.id);
            }
          } catch (_) {
            _preloadedDistrictId = null; // Clear even if not found
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDistricts = false);
      }
    }
  }

  // Load cities by state
  Future<void> _loadCities(int stateId) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _selectedCity = null;
      // _regions = []; // Removed
      // _selectedRegion = null; // Removed
    });

    try {
      final repository = ref.read(onboardingRepositoryProvider);
      final cities = await repository.getCities(stateId);

      if (mounted) {
        setState(() {
          _cities = cities;
          _isLoadingCities = false;
        });

        // Match preloaded city ID
        if (_preloadedCityId != null && cities.isNotEmpty) {
          try {
            final match =
                cities.firstWhere((item) => item.id == _preloadedCityId);
            setState(() {
              _selectedCity = match;
              _preloadedCityId = null; // Clear after matching
            });
          } catch (_) {
            _preloadedCityId = null; // Clear even if not found
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCities = false);
      }
    }
  }

  /*
  // Load regions by city
  Future<void> _loadRegions(int cityId) async {
     // ... method removed ...
  }
  */

  // Load communities
  /*
  // Load communities
  Future<void> _loadCommunities({int? id}) async {
     // ... method removed ...
  }
  */

  // Load existing profile data to prefill form fields
  // Load existing profile data to prefill form fields
  Future<void> _loadExistingProfile() async {
    setState(() {
      _isLoadingInitialData = true;
    });

    try {
      // Clear caches to force fresh data fetch
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.clearProfileCache();
      print('🗑️ [Onboarding] Profile cache cleared, fetching fresh data');

      final profile = await profileRepo.getProfile();

      if (!mounted) return;

      // Update text controllers with existing data
      if (profile.firstName != null && profile.firstName!.isNotEmpty) {
        _firstNameController.text = profile.firstName!;
      }
      if (profile.lastName != null && profile.lastName!.isNotEmpty) {
        _lastNameController.text = profile.lastName!;
      }
      if (profile.email != null && profile.email!.isNotEmpty) {
        _emailController.text = profile.email!;
      }
      if (profile.mobile != null && profile.mobile!.isNotEmpty) {
        _mobileController.text = profile.mobile!;
      }
      if (profile.dob != null && profile.dob!.isNotEmpty) {
        // Sanitize backend DOB (may contain time) and parse to DateTime
        final parsed = _parseBackendDate(profile.dob!);
        if (parsed != null) {
          _selectedDob = parsed;
          // Display as DD-MM-YYYY in the field (clean, no time)
          _dobController.text =
              '${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year}';
        } else {
          // Fallback: strip time portion and show whatever date-like prefix exists
          final cleaned = profile.dob!.split(' ').first.split('T').first;
          _dobController.text = cleaned;
          try {
            _selectedDob = DateTime.parse(cleaned);
          } catch (e) {}
        }
      }

      // Phase 1: Address
      if (profile.street != null) {
        _streetController.text = profile.street!;
      }
      if (profile.pincode != null) {
        _pincodeController.text = profile.pincode!;
      }
      if (profile.region != null) {
        _regionController.text = profile.region!;
      }

      // Load uploaded image filename from backend
      if (profile.imageFile != null && profile.imageFile!.isNotEmpty) {
        setState(() {
          _uploadedImageFileName = profile.imageFile;
        });
        print(
          '✅ [ImageFlow] Loaded existing image from profile: ${profile.imageFile}',
        );
      } else {
        print('ℹ️ [ImageFlow] No existing image found in profile');
      }

      setState(() {
        // Store IDs to match with dropdown data when it loads
        _preloadedNameTitleId = profile.nameTitleId;

        // Location IDs - CRITICAL: All location IDs must be set for cascade chain
        _preloadedCountryId = profile.countryId;
        _preloadedStateId = profile.stateId;
        _preloadedDistrictId = profile.districtId;
        _preloadedCityId = profile.cityId;
      });

      // Debug log to confirm IDs are loaded
      print('📍 [Onboarding] Location IDs loaded from profile:');
      print('   Country: $_preloadedCountryId');
      print('   State: $_preloadedStateId');
      print('   District: $_preloadedDistrictId');
      print('   City: $_preloadedCityId');

      // Load location data hierarchically
      // Country dropdown will handle matching and chaining to states automatically
      // when countriesProvider loads (no manual loading needed here)

      // Mark profile as loaded - this allows the country dropdown to start the cascade
      if (mounted) {
        setState(() {
          _profileLoaded = true;
          _isLoadingInitialData = false;
          // Store initial values for change detection
          _initialProfileData = {
            'nameTitleId': profile.nameTitleId,
            'firstName': profile.firstName,
            'lastName': profile.lastName,
            'mobile': profile.mobile,
            'email': profile.email,
            'dob': profile.dob,
            'street': profile.street,
            'countryId': profile.countryId,
            'stateId': profile.stateId,
            'districtId': profile.districtId,
            'cityId': profile.cityId,
            'region': profile.region,
            'pincode': profile.pincode,
            'imageFile': profile.imageFile,
          };
        });
        print('✅ [Onboarding] Profile loaded, ready for cascade');
        print('📊 [ChangeTracking] Initial profile data stored');
      }
    } catch (e) {
      // If profile fetch fails, it means user hasn't saved profile yet
      // Just use the data from registration (already in controllers)
      print('⚠️ [Onboarding] Profile fetch failed or new user: $e');
      if (mounted) {
        setState(() {
          _profileLoaded = true; // Still mark as loaded so UI works
          _isLoadingInitialData = false;
        });
      }
    }
  }

  /// Check if current phase has any changes compared to initial data
  bool _hasCurrentPhaseChanges() {
    try {
      switch (_currentPhase) {
        case 0: // Basic Details
          return _selectedNameTitle?.id != _initialProfileData['nameTitleId'] ||
              _firstNameController.text.trim() !=
                  (_initialProfileData['firstName'] ?? '') ||
              _lastNameController.text.trim() !=
                  (_initialProfileData['lastName'] ?? '') ||
              _mobileController.text.trim() !=
                  (_initialProfileData['mobile'] ?? '') ||
              _emailController.text.trim() !=
                  (_initialProfileData['email'] ?? '') ||
              _dobController.text.trim() !=
                  (_initialProfileData['dob'] ?? '') ||
              _uploadedImageFileName != _initialProfileData['imageFile'];
        case 1: // Address
          return _selectedCountry?.id != _initialProfileData['countryId'] ||
              _selectedState?.id != _initialProfileData['stateId'] ||
              _selectedDistrict?.id != _initialProfileData['districtId'] ||
              _selectedCity?.id != _initialProfileData['cityId'] ||
              _regionController.text.trim() !=
                  (_initialProfileData['region'] ?? '') ||
              _streetController.text.trim() !=
                  (_initialProfileData['street'] ?? '') ||
              _pincodeController.text.trim() !=
                  (_initialProfileData['pincode'] ?? '');

        default:
          return false;
      }
    } catch (e) {
      print('⚠️ [ChangeTracking] Error checking changes: $e');
      return true; // If error, assume there are changes to be safe
    }
  }

  /// Check Phase 0 (Basic) changes
  bool _hasPhase0Changes() {
    return _selectedNameTitle?.id != _initialProfileData['nameTitleId'] ||
        _firstNameController.text.trim() !=
            (_initialProfileData['firstName'] ?? '') ||
        _lastNameController.text.trim() !=
            (_initialProfileData['lastName'] ?? '') ||
        _mobileController.text.trim() !=
            (_initialProfileData['mobile'] ?? '') ||
        _emailController.text.trim() != (_initialProfileData['email'] ?? '') ||
        _dobController.text.trim() != (_initialProfileData['dob'] ?? '') ||
        _uploadedImageFileName != _initialProfileData['imageFile'];
  }

  /// Check Phase 1 (Address) changes
  bool _hasPhase1Changes() {
    return _selectedCountry?.id != _initialProfileData['countryId'] ||
        _selectedState?.id != _initialProfileData['stateId'] ||
        _selectedDistrict?.id != _initialProfileData['districtId'] ||
        _selectedCity?.id != _initialProfileData['cityId'] ||
        _regionController.text.trim() !=
            (_initialProfileData['region'] ?? '') ||
        _streetController.text.trim() !=
            (_initialProfileData['street'] ?? '') ||
        _pincodeController.text.trim() !=
            (_initialProfileData['pincode'] ?? '');
  }

  /// Build SaveUserRequest with all current form values.
  /// Backend requires mandatory fields (firstName, lastName, email, mobile) on every save.
  /// toJson() filters out empty/null values automatically.
  SaveUserRequest _buildChangedFieldsRequest(int userId) {
    // Format DOB as string
    String? dobString;
    if (_selectedDob != null) {
      dobString =
          '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}';
    }

    // Parse pincode
    final pincode = int.tryParse(_pincodeController.text.trim());

    print('📤 [SaveUser] Building request with current form values...');

    return SaveUserRequest(
      id: userId,
      nameTitleId: _selectedNameTitle?.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      dob: dobString,
      street: _streetController.text.trim(),
      countryId: _selectedCountry?.id,
      stateId: _selectedState?.id,
      districtId: _selectedDistrict?.id,
      cityId: _selectedCity?.id,
      region: _regionController.text.trim(),
      pincode: pincode,
      imageFile: _uploadedImageFileName,
    );
  }

  /// Pick and crop a profile image with high quality settings
  Future<void> _pickImage() async {
    try {
      // Use ImagePickerHelper with improved quality settings to prevent blur/stretch
      final croppedImage = await ImagePickerHelper.pickAndCropImage(
        context: context,
        source: ImageSource.gallery,
        aspectRatioPreset: ImageAspectRatioPreset.square,
        cropShape: ImageCropShape.rectangle,
        maxWidth: 2048, // Increased from 512 to preserve quality
        maxHeight: 2048, // Increased from 512 to preserve quality
        imageQuality: 95, // Increased from 90 for better quality
      );

      if (croppedImage != null) {
        setState(() {
          _profileImage = croppedImage;
          _isUploadingImage = true;
        });

        // Upload the image immediately after cropping
        try {
          final repository = ref.read(profileRepositoryProvider);
          final uploadedFileName = await repository.uploadUserImage(
            croppedImage,
          );

          if (mounted) {
            setState(() {
              _uploadedImageFileName = uploadedFileName;
              _isUploadingImage = false;
            });
            print(
              '✅ [ImageFlow] Image uploaded successfully: $uploadedFileName',
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isUploadingImage = false;
              _profileImage = null;
            });
            await AppDialogs.showError(
              context,
              message: 'Failed to upload image. Please try again.',
              title: 'Upload Error',
            );
          }
          print('❌ [ImageFlow] Image upload failed: $e');
        }
      }
    } catch (e) {
      print('❌ [ImageFlow] Error picking image: $e');
      if (mounted) {
        await AppDialogs.showError(
          context,
          message: 'Failed to pick image. Please try again.',
          title: 'Error',
        );
      }
    }
  }

  void _onNext() async {
    // Validate current phase
    switch (_currentPhase) {
      case 0:
        // Validate Phase 0 (Basic)
        final errors = <String>[];
        if (_selectedNameTitle == null) {
          errors.add('Please select your title');
        }
        if (_firstNameController.text.trim().isEmpty) {
          errors.add('Please enter your first name');
        }
        if (_lastNameController.text.trim().isEmpty) {
          errors.add('Please enter your last name');
        }
        if (_selectedDob == null) {
          // Fallback: if the DOB controller has a value (user selected it),
          // try to parse and set `_selectedDob` so validation doesn't fail
          // erroneously when only the controller was updated.
          if (_dobController.text.trim().isNotEmpty) {
            try {
              final txt = _dobController.text.trim();
              // Accept formats like dd/MM/yyyy or dd-MM-yyyy
              final parts = txt.contains('/') ? txt.split('/') : txt.split('-');
              if (parts.length == 3) {
                final day = int.parse(parts[0]);
                final month = int.parse(parts[1]);
                final year = int.parse(parts[2]);
                _selectedDob = DateTime(year, month, day);
              }
            } catch (_) {
              errors.add('Please select your date of birth');
            }

            if (_selectedDob == null) {
              errors.add('Please select your date of birth');
            }
          } else {
            errors.add('Please select your date of birth');
          }
        }
        if (_mobileController.text.trim().isEmpty) {
          errors.add('Please enter your mobile number');
        }
        if (_emailController.text.trim().isEmpty) {
          errors.add('Please enter your email');
        }
        // Make profile photo mandatory
        if (_profileImage == null && _uploadedImageFileName == null) {
          errors.add('Please upload your profile photo');
        }

        if (errors.isNotEmpty) {
          AppDialogs.showValidationErrors(context, errors: errors);
          return;
        }
        break;

      case 1:
        // Validate Address phase
        final hasAnyAddressData = _selectedCountry != null ||
            _selectedState != null ||
            _selectedDistrict != null ||
            _selectedCity != null ||
            _streetController.text.trim().isNotEmpty ||
            _pincodeController.text.trim().isNotEmpty ||
            _regionController.text.trim().isNotEmpty;

        if (hasAnyAddressData) {
          final errors = <String>[];
          if (_selectedCountry == null) {
            errors.add('Please select your country');
          }
          if (_selectedState == null) {
            errors.add('Please select your state');
          }
          if (_selectedDistrict == null) {
            errors.add('Please select your district');
          }
          if (_selectedCity == null) {
            errors.add('Please select your city');
          }
          if (_streetController.text.trim().isEmpty) {
            errors.add('Please enter your street address');
          }
          if (_pincodeController.text.trim().isEmpty) {
            errors.add('Please enter your pincode');
          }
          if (_regionController.text.trim().isEmpty) {
            errors.add('Please enter your region');
          }

          if (errors.isNotEmpty) {
            AppDialogs.showValidationErrors(context, errors: errors);
            return;
          }
        }
        break;
    }

    // Save behavior based on mode:
    // - Onboarding mode: Save on every Next (progressive save) - but only if there are changes
    // - Edit mode: Don't save until final Save button (save all at once)
    if (!widget.isEditMode) {
      // Check if current phase has changes
      final hasChanges = _hasCurrentPhaseChanges();

      if (hasChanges) {
        print(
          '📝 [ChangeTracking] Phase $_currentPhase has changes, saving...',
        );
        final saved = await _saveCurrentPhase();
        if (!saved) return; // Stop if save failed
      } else {
        print(
          '✅ [ChangeTracking] Phase $_currentPhase has no changes, skipping save',
        );
      }
    }

    // Move to next phase
    if (_currentPhase < _totalPhases - 1) {
      setState(() => _currentPhase++);
    }
  }

  /// Save current phase data to API
  Future<bool> _saveCurrentPhase() async {
    // Wait if image upload is still in progress
    if (_isUploadingImage) {
      // Wait up to 30 seconds for upload to complete
      int waitCount = 0;
      while (_isUploadingImage && waitCount < 60) {
        await Future.delayed(const Duration(milliseconds: 500));
        waitCount++;
      }
      if (_isUploadingImage) {
        if (mounted) {
          await AppDialogs.showError(
            context,
            message: 'Image upload is taking too long. Please try again.',
            title: 'Upload Timeout',
          );
        }
        return false;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Get user ID
      final localStorage = LocalStorage.instance;
      String? userId = localStorage.getString('user_id');

      if (userId == null || userId.isEmpty) {
        try {
          final profileRepo = ref.read(profileRepositoryProvider);
          final profile = await profileRepo.getProfile();
          userId = profile.id;
          if (userId.isNotEmpty) {
            await localStorage.setString('user_id', userId);
          }
        } catch (e) {}
      }

      if (userId == null || userId.isEmpty) {
        setState(() => _isLoading = false);
        if (mounted) {
          await AppDialogs.showError(
            context,
            message: 'User ID not found. Please login again.',
            title: 'Error',
          );
        }
        return false;
      }

      // Build request with ONLY changed fields + id
      final request = _buildChangedFieldsRequest(int.parse(userId));

      print('📤 [ChangeTracking] Saving user data with changes...');

      // Call API
      final repository = ref.read(onboardingRepositoryProvider);
      final response = await repository.saveUser(request);

      setState(() => _isLoading = false);

      if (!response.success) {
        if (mounted) {
          await AppDialogs.showError(
            context,
            message: response.message ?? 'Failed to save profile',
            title: 'Error Invite Code',
          );
        }
        return false;
      }

      // Refresh profile cache to ensure UI shows updated data
      try {
        final profileRepo = ref.read(profileRepositoryProvider);
        final updatedProfile = await profileRepo.getProfile();

        // Update initial data with saved values for next change detection
        if (mounted) {
          setState(() {
            _initialProfileData = {
              'nameTitleId': updatedProfile.nameTitleId,
              'firstName': updatedProfile.firstName,
              'lastName': updatedProfile.lastName,
              'mobile': updatedProfile.mobile,
              'email': updatedProfile.email,
              'dob': updatedProfile.dob,
              'street': updatedProfile.street,
              'countryId': updatedProfile.countryId,
              'stateId': updatedProfile.stateId,
              'districtId': updatedProfile.districtId,
              'cityId': updatedProfile.cityId,
              'region': updatedProfile.region,
              'pincode': updatedProfile.pincode,
              'imageFile': updatedProfile.imageFile,
            };
          });
        }
        print('✅ [OnboardingScreen] Profile cache refreshed after save');
        print('📊 [ChangeTracking] Initial data updated after save');
      } catch (e) {
        print('⚠️ [OnboardingScreen] Could not refresh profile cache: $e');
      }

      return true;
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        await AppDialogs.showError(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          title: 'Error',
        );
      }
      return false;
    }
  }

  /// Header back button - always shows confirmation dialog
  void _onHeaderBackPressed() async {
    // In edit mode, show confirmation before going back
    if (widget.isEditMode) {
      final confirmed = await AppDialogs.showConfirmation(
        context,
        title: 'Discard Changes?',
        message:
            'Are you sure you want to go back? Any unsaved changes will be lost.',
        confirmText: 'Yes',
        cancelText: 'Cancel',
      );

      if (confirmed == true && mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    // In onboarding mode, show confirmation and clear data
    final confirmed = await AppDialogs.showConfirmation(
      context,
      title: 'Exit Onboarding?',
      message: 'Are you sure you want to go back? Your progress will be lost.',
      confirmText: 'Yes',
      cancelText: 'Cancel',
    );

    if (confirmed == true && mounted) {
      // Clear onboarding data and navigate to register screen
      final localStorage = LocalStorage.instance;
      await localStorage.setBool(AppConstants.keyIsLoggedIn, false);
      await localStorage.setBool(AppConstants.keyProfileSaved, false);
      await localStorage.setBool(
        AppConstants.keyRegistrationOnboardingPending,
        false,
      );
      await SecureStorage.instance.delete('auth_token');

      // Navigate to register screen, clearing the entire navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.register,
        (route) => false,
      );
    }
  }

  void _onBack() async {
    if (_currentPhase > 0) {
      setState(() => _currentPhase--);
    } else {
      // In edit mode, show confirmation before going back
      if (widget.isEditMode) {
        final confirmed = await AppDialogs.showConfirmation(
          context,
          title: 'Discard Changes?',
          message:
              'Are you sure you want to go back? Any unsaved changes will be lost.',
          confirmText: 'Yes',
          cancelText: 'Cancel',
        );

        if (confirmed == true && mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      // In onboarding mode, show confirmation and clear data
      final confirmed = await AppDialogs.showConfirmation(
        context,
        title: 'Exit Onboarding?',
        message:
            'Are you sure you want to go back? Your progress will be lost.',
        confirmText: 'Yes',
        cancelText: 'Cancel',
      );

      if (confirmed == true && mounted) {
        // Clear onboarding data and navigate to register screen
        final localStorage = LocalStorage.instance;
        await localStorage.setBool(AppConstants.keyIsLoggedIn, false);
        await localStorage.setBool(AppConstants.keyProfileSaved, false);
        await localStorage.setBool(
          AppConstants.keyRegistrationOnboardingPending,
          false,
        );
        await SecureStorage.instance.delete('auth_token');

        // Navigate to register screen, clearing the entire navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.register,
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleSkip() async {
    // Show confirmation dialog before skipping
    final confirmed = await AppDialogs.showConfirmation(
      context,
      title: 'Skip Onboarding?',
      message:
          'Are you sure you want to skip the onboarding process? You can complete it later from your profile.',
      confirmText: 'Yes',
      cancelText: 'Cancel',
    );

    if (confirmed != true) return;

    final localStorage = LocalStorage.instance;
    // Mark profile as saved/onboarding completed so verification doesn't block
    await localStorage.setBool(AppConstants.keyProfileSaved, true);
    await localStorage.setBool(
      AppConstants.keyRegistrationOnboardingPending,
      false,
    );

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.home,
        (route) => false,
      );
    }
  }

  void _onSave() async {
    // Final save button:
    // - Edit mode: Save ALL profile data (single save at end)
    // - Onboarding mode: Profile already saved progressively, just complete onboarding

    // Wait if image upload is still in progress
    if (_isUploadingImage) {
      // Wait up to 30 seconds for upload to complete
      int waitCount = 0;
      while (_isUploadingImage && waitCount < 60) {
        await Future.delayed(const Duration(milliseconds: 500));
        waitCount++;
      }
      if (_isUploadingImage) {
        if (mounted) {
          await AppDialogs.showError(
            context,
            message: 'Image upload is taking too long. Please try again.',
            title: 'Upload Timeout',
          );
        }
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Get user ID
      final localStorage = LocalStorage.instance;
      String? userId = localStorage.getString('user_id');

      if (userId == null || userId.isEmpty) {
        try {
          final profileRepo = ref.read(profileRepositoryProvider);
          final profile = await profileRepo.getProfile();
          userId = profile.id;
          if (userId.isNotEmpty) {
            await localStorage.setString('user_id', userId);
          }
        } catch (e) {}
      }

      if (userId == null || userId.isEmpty) {
        setState(() => _isLoading = false);
        if (mounted) {
          await AppDialogs.showError(
            context,
            message: 'User ID not found. Please login again.',
            title: 'Error',
          );
        }
        return;
      }

      // In edit mode, save profile data first (all phases at once) - but only if there are changes
      if (widget.isEditMode) {
        // Check if any profile data has changed across all phases
        final hasProfileChanges = _hasCurrentPhaseChanges() ||
            (_currentPhase == 0 && _hasPhase0Changes()) ||
            (_currentPhase == 1 && _hasPhase1Changes());

        if (hasProfileChanges || _initialProfileData.isEmpty) {
          print(
            '📝 [ChangeTracking] Edit mode: Profile has changes, saving...',
          );

          // Build request with ONLY changed fields + id
          final request = _buildChangedFieldsRequest(int.parse(userId));

          // Call API
          final repository = ref.read(onboardingRepositoryProvider);
          final response = await repository.saveUser(request);

          if (!response.success) {
            setState(() => _isLoading = false);
            if (mounted) {
              await AppDialogs.showError(
                context,
                message: response.message ?? 'Failed to save profile',
                title: 'Error',
              );
            }
            return;
          }

          // Refresh profile cache to ensure UI shows updated data and update initial data
          try {
            final profileRepo = ref.read(profileRepositoryProvider);
            final updatedProfile = await profileRepo.getProfile();

            // Update initial data with saved values for next change detection
            if (mounted) {
              setState(() {
                _initialProfileData = {
                  'nameTitleId': updatedProfile.nameTitleId,
                  'firstName': updatedProfile.firstName,
                  'lastName': updatedProfile.lastName,
                  'mobile': updatedProfile.mobile,
                  'email': updatedProfile.email,
                  'dob': updatedProfile.dob,
                  'genderId': updatedProfile.genderId,
                  'bloodGroupId': updatedProfile.bloodGroupId,
                  'height': updatedProfile.height?.toString(),
                  'weight': updatedProfile.weight?.toString(),
                  'tshirtSizeId': updatedProfile.tshirtSizeId,
                  'foodPreferenceId': updatedProfile.foodPreferenceId,
                  'street': updatedProfile.street,
                  'countryId': updatedProfile.countryId,
                  'stateId': updatedProfile.stateId,
                  'districtId': updatedProfile.districtId,
                  'cityId': updatedProfile.cityId,
                  'region': updatedProfile.region,
                  'pincode': updatedProfile.pincode,
                  'imageFile': updatedProfile.imageFile,
                };
              });
            }
            print(
              '✅ [OnboardingScreen] Profile cache refreshed after edit save',
            );
            print('📊 [ChangeTracking] Initial data updated after edit save');
          } catch (e) {
            print('⚠️ [OnboardingScreen] Could not refresh profile cache: $e');
          }
        } else {
          print(
            '✅ [ChangeTracking] Edit mode: No profile changes detected, skipping save',
          );
        }
      }

      setState(() => _isLoading = false);

      if (mounted) {
        // Set profile_saved flag to true
        await localStorage.setBool(AppConstants.keyProfileSaved, true);

        // Clear registration onboarding pending flag
        await localStorage.setBool(
          AppConstants.keyRegistrationOnboardingPending,
          false,
        );

        await AppDialogs.showSuccess(
          context,
          message: widget.isEditMode
              ? 'Profile updated successfully!'
              : 'Onboarding completed successfully!',
          title: widget.isEditMode ? 'Success!' : 'Welcome!',
        );
        // Navigate based on mode
        if (mounted) {
          if (widget.isEditMode) {
            // Clear profile cache to force fresh fetch
            final profileDataSource = ref.read(profileRemoteDataSourceProvider);
            await profileDataSource.clearProfileCache();
            print(
              '✅ [OnboardingScreen] Profile cache cleared - will refresh on profile screen',
            );
            // In edit mode, just go back to profile page (it will auto-reload)
            Navigator.of(context)
                .pop(true); // Pass true to indicate data changed
          } else {
            // In onboarding mode, navigate to home screen
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.home,
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        await AppDialogs.showError(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          title: 'Error',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title only
            _buildHeaderTitle(context),
            // Divider FIRST as per UI
            Container(
              height: 1,
              color: Colors.grey.shade200,
            ),
            // Progress bar AFTER divider
            Padding(
              padding:
                  AppResponsive.padding(context, horizontal: 24, vertical: 16),
              child: _buildProgressIndicator(context),
            ),
            // Content
            Expanded(
              child: _isLoadingInitialData
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppLoading.circular(
                            color: AppColors.accentBlue,
                            size: AppResponsive.s(context, 50),
                          ),
                          SizedBox(height: AppResponsive.s(context, 16)),
                          Text(
                            'Loading profile data...',
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 16),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: AppResponsive.padding(context, horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppResponsive.s(context, 8)),
                          // Phase content
                          _buildPhaseContent(context),
                          SizedBox(height: AppResponsive.s(context, 32)),
                        ],
                      ),
                    ),
            ),
            // Bottom buttons using global AppButtonPair
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTitle(BuildContext context) {
    return Padding(
      padding:
          AppResponsive.padding(context, horizontal: 20, top: 5, bottom: 16),
      child: Row(
        children: [
          AppBackButton(
            size: AppResponsive.s(context, 48),
            onPressed: _onHeaderBackPressed,
            backgroundColor: const Color(0xFFE5E5E5),
            iconColor: Colors.black,
          ),
          SizedBox(width: AppResponsive.s(context, 16)),
          Text(
            widget.isEditMode ? 'Edit Profile' : 'Onboarding Screen',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: AppResponsive.font(context, 22),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          // Hide Skip button in edit mode, sports only, and on last phase (Proficiency)
          if (!widget.isEditMode && _currentPhase != _totalPhases - 1)
            GestureDetector(
              onTap: _handleSkip,
              child: Text(
                'Skip',
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 14),
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    // Only Basic and Address phases are available now
    final phases = ['Basic', 'Address'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(phases.length * 2 - 1, (index) {
        // Handle spacing items (odd indices)
        if (index.isOdd) {
          return SizedBox(width: AppResponsive.s(context, 4));
        }

        // Handle content items (even indices -> phase index = index ~/ 2)
        final phaseIndex = index ~/ 2;
        final isCompleted = phaseIndex < _currentPhase;
        final isActive = phaseIndex <= _currentPhase;

        return Expanded(
          child: Column(
            children: [
              // Progress Bar
              Container(
                height: AppResponsive.s(context, 6),
                width: double.infinity,
                decoration: BoxDecoration(
                  // Only completed phases are blue. Current step remains gray until done.
                  color: isCompleted
                      ? AppColors.accentBlue
                      : const Color(0xFFE0E0E0),
                  borderRadius: AppResponsive.borderRadius(context, 3),
                ),
              ),
              SizedBox(height: AppResponsive.s(context, 8)),
              // Phase Label
              Text(
                phases[phaseIndex],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: AppResponsive.font(context, 12),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isCompleted
                      ? AppColors.accentBlue
                      : (isActive
                          ? AppColors.textPrimaryLight
                          : AppColors.textMutedLight),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPhaseContent(BuildContext context) {
    switch (_currentPhase) {
      case 0:
        return _buildPhaseBasic(context);
      case 1:
        return _buildPhaseAddress(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageUploadSection() {
    // Check if we have an uploaded image from profile (edit mode)
    final hasUploadedImage =
        _uploadedImageFileName != null && _uploadedImageFileName!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: _profileImage == null && !hasUploadedImage
          ? AppResponsive.padding(context, all: 20)
          : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppResponsive.borderRadius(context, 12),
        border: Border.all(
          color: Colors.black,
          width: AppResponsive.thickness(context, 1.5),
        ),
      ),
      child: _profileImage != null
          ? Stack(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: ClipRRect(
                    borderRadius: AppResponsive.borderRadius(context, 12),
                    child: Image.file(
                      _profileImage!,
                      width: double.infinity,
                      height: AppResponsive.s(context, 200),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _profileImage = null;
                        _uploadedImageFileName = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : hasUploadedImage
              ? Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: ClipRRect(
                        borderRadius: AppResponsive.borderRadius(context, 12),
                        child: Builder(
                          builder: (context) {
                            final imageUrl = ref
                                .read(profileRepositoryProvider)
                                .getUserImageUrl(_uploadedImageFileName);
                            print(
                              '🖼️ [OnboardingScreen] Displaying image URL: $imageUrl',
                            );
                            return CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: double.infinity,
                              height: AppResponsive.s(context, 200),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: AppLoading.circular(),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print(
                                  '❌ [OnboardingScreen] Image load error: $error',
                                );
                                print('❌ [OnboardingScreen] Failed URL: $url');
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _uploadedImageFileName = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Center(
                      child: Container(
                        width: AppResponsive.s(context, 64),
                        height: AppResponsive.s(context, 64),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person_outline,
                            size: AppResponsive.icon(context, 36),
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppResponsive.s(context, 10)),
                    Text(
                      'Upload your Image',
                      style: TextStyle(
                        fontSize: AppResponsive.font(context, 16),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: AppResponsive.s(context, 10)),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppResponsive.s(context, 16),
                          ),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: AppResponsive.font(context, 14),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    SizedBox(height: AppResponsive.s(context, 16)),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: AppResponsive.s(context, 5),
                          horizontal: AppResponsive.s(context, 12),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: AppResponsive.borderRadius(context, 8),
                        ),
                        child: Text(
                          'Browse Photo',
                          style: TextStyle(
                            fontSize: AppResponsive.font(context, 12),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPhaseBasic(BuildContext context) {
    final nameTitlesAsync = ref.watch(nameTitlesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageUploadSection(),
        SizedBox(height: AppResponsive.s(context, 16)),
        // Name Title Dropdown (Mr./Mrs./Ms.)
        nameTitlesAsync.when(
          data: (titles) {
            // Match preloaded ID with loaded data
            if (_preloadedNameTitleId != null && _selectedNameTitle == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final match = titles.firstWhere(
                  (item) => item.id == _preloadedNameTitleId,
                  orElse: () => titles.first,
                );
                if (mounted) {
                  setState(() {
                    _selectedNameTitle = match;
                    _preloadedNameTitleId = null; // Clear after matching
                  });
                }
              });
            }

            return AppDropdown<TypeDataItem>(
              label: 'Title',
              value: _selectedNameTitle,
              items: titles,
              onChanged: (value) {
                setState(() => _selectedNameTitle = value);
              },
              itemLabel: (item) => item.name,
              isRequired: true,
            );
          },
          loading: () {
            return AppDropdown<TypeDataItem>(
              label: 'Title',
              value: null,
              items: const [],
              isLoading: true,
              onChanged: (_) {},
              itemLabel: (item) => item.name,
            );
          },
          error: (error, stack) {
            return AppDropdown<TypeDataItem>(
              label: 'Title',
              value: null,
              items: const [],
              onChanged: (_) {},
              itemLabel: (item) => item.name,
            );
          },
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // First Name
        AppTextFieldWithLabel(
          controller: _firstNameController,
          // readOnly: true,
          label: 'First Name',
          hintText: 'First Name',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          // backgroundColor: const Color(0xFFEEEEEE),
          isRequired: true,
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // Last Name
        AppTextFieldWithLabel(
          controller: _lastNameController,
          // readOnly: true,
          label: 'Last Name',
          hintText: 'Last Name',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          // backgroundColor: const Color(0xFFEEEEEE),
          isRequired: true,
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // Date of Birth
        GestureDetector(
          onTap: () => _selectDob(context),
          child: AbsorbPointer(
            child: AppTextFieldWithLabel(
              controller: _dobController,
              label: 'Date of Birth',
              hintText: 'Date of Birth',
              keyboardType: TextInputType.datetime,
              textInputAction: TextInputAction.next,
              isRequired: true,
              // backgroundColor: const Color(0xFFEEEEEE),
              suffixIcon: Icon(
                Icons.calendar_today,
                size: AppResponsive.icon(context, 20),
                color: AppColors.textMutedLight,
              ),
            ),
          ),
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // Mobile No.
        AppTextFieldWithLabel(
          controller: _mobileController,
          readOnly: true,
          label: 'Mobile No.',
          hintText: 'Mobile No.',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          backgroundColor: const Color(0xFFEEEEEE),
          isRequired: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // Email ID
        AppTextFieldWithLabel(
          controller: _emailController,
          readOnly: true,
          label: 'Email ID',
          hintText: 'Email ID',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          backgroundColor: const Color(0xFFEEEEEE),
          isRequired: true,
        ),
      ],
    );
  }

  Future<void> _selectDob(BuildContext context) async {
    final now = DateTime.now();
    final initialDate =
        _selectedDob ?? DateTime(now.year - 18, now.month, now.day);
    final firstDate = DateTime(1920);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimaryLight,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Widget _buildPhaseAddress(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country
        countriesAsync.when(
          data: (countries) {
            // Match preloaded ID with loaded data
            // Only attempt matching if profile has been loaded (IDs are set)
            if (_profileLoaded &&
                _preloadedCountryId != null &&
                _selectedCountry == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Double-check conditions inside callback as state may have changed
                if (!mounted ||
                    _preloadedCountryId == null ||
                    _selectedCountry != null) {
                  return;
                }

                try {
                  final match = countries.firstWhere(
                    (item) => item.id == _preloadedCountryId,
                  );
                  if (mounted) {
                    print(
                      '✅ [Onboarding] Country matched in dropdown: ID=${match.id}, Name=${match.name}',
                    );
                    setState(() {
                      _selectedCountry = match;
                    });

                    // Clear preloaded ID and trigger location chain
                    final countryIdToLoad = _preloadedCountryId;
                    _preloadedCountryId = null;

                    // Chain: Load states if state ID is preloaded
                    if (countryIdToLoad != null && _preloadedStateId != null) {
                      print(
                        '🔄 [Onboarding] Chain: Loading states for countryId=$countryIdToLoad',
                      );
                      _loadStatesWithChain(countryIdToLoad);
                    } else {
                      print(
                        'ℹ️ [Onboarding] No state ID preloaded, cascade ends at country',
                      );
                    }
                  }
                } catch (_) {
                  print(
                    '⚠️ [Onboarding] Country not found for ID=$_preloadedCountryId',
                  );
                  _preloadedCountryId = null;
                }
              });
            }

            return AppDropdown<CountryModel>(
              label: 'Country',
              value: _selectedCountry,
              items: countries,
              onChanged: (country) {
                setState(() {
                  _selectedCountry = country;
                  _selectedState = null;
                  _selectedDistrict = null;
                  _selectedCity = null;
                  _states = [];
                  _districts = [];
                  _cities = [];
                });
                if (country != null) {
                  _loadStates(country.id);
                }
              },
              itemLabel: (country) => country.name,
            );
          },
          loading: () => AppDropdown<CountryModel>(
            label: 'Country',
            value: null,
            items: const [],
            isLoading: true,
            onChanged: (_) {},
            itemLabel: (country) => country.name,
          ),
          error: (_, __) => AppDropdown<CountryModel>(
            label: 'Country',
            value: null,
            items: const [],
            onChanged: (_) {},
            itemLabel: (country) => country.name,
          ),
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // State
        AppDropdown<StateModel>(
          label: 'State',
          value: _selectedState,
          items: _states,
          isLoading: _isLoadingStates,
          enabled: _selectedCountry != null,
          onChanged: (state) {
            setState(() {
              _selectedState = state;
              _selectedDistrict = null;
              _selectedCity = null;
              _districts = [];
              _cities = [];
            });
            if (state != null) {
              _loadDistricts(state.id);
              // New method: Load cities directly using stateId
              _loadCities(state.id);
            }
          },
          itemLabel: (state) => state.name,
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // District
        AppDropdown<DistrictModel>(
          label: 'District',
          value: _selectedDistrict,
          items: _districts,
          isLoading: _isLoadingDistricts,
          enabled: _selectedState != null,
          onChanged: (district) {
            setState(() {
              _selectedDistrict = district;
              // Note: Cities are now loaded by stateId, not districtId
              // Commenting out city clearing and loading by district
              // _selectedCity = null;
              // _cities = [];
            });
            // Old method (commented): Loading cities by districtId
            // if (district != null) {
            //   _loadCities(district.id);
            // }
          },
          itemLabel: (district) => district.name,
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // City (Now loaded by stateId instead of districtId)
        AppDropdown<CityModel>(
          label: 'City',
          value: _selectedCity,
          items: _cities,
          isLoading: _isLoadingCities,
          enabled: _selectedState != null && !_isLoadingCities,
          onChanged: (city) {
            setState(() {
              _selectedCity = city;
            });
          },
          itemLabel: (city) => city.name,
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // Region (Converted to Text Field)
        AppTextFieldWithLabel(
          controller: _regionController,
          label: 'Region',
          hintText: 'Enter your region',
          keyboardType: TextInputType.text,
          validator: (value) {
            return null;
          },
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // Street Address
        AppTextFieldWithLabel(
          controller: _streetController,
          label: 'Street Address',
          hintText: 'Street Address',
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // Pincode
        AppTextFieldWithLabel(
          controller: _pincodeController,
          label: 'Pincode',
          hintText: 'Pincode',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        SizedBox(height: AppResponsive.s(context, 16)),
        // Community Removed
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    final isLastPhase = _currentPhase == _totalPhases - 1;
    final isFirstPhase = _currentPhase == 0;

    return AppButtonPair(
      onBack: _onBack,
      onNext: isLastPhase ? _onSave : _onNext,
      backText: 'Back',
      nextText: isLastPhase ? 'Save' : 'Next',
      showBack: !isFirstPhase,
      isLoading: _isLoading,
    );
  }
}
