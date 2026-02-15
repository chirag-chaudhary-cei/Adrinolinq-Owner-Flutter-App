import 'dart:io';

import 'package:adrinolinq_owner/core/widgets/app_dropdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/utils/image_crop_config.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../auth/presentation/providers/onboarding_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/models/manager_team_model.dart';
import '../../data/models/save_team_request.dart';
import '../providers/teams_providers.dart';

/// Create or Edit Team Page
class CreateTeamPage extends ConsumerStatefulWidget {
  const CreateTeamPage({super.key, this.team});

  final ManagerTeamModel? team;

  @override
  ConsumerState<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends ConsumerState<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _profileImage;
  String? _uploadedImageFileName;
  dynamic _selectedSport;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  bool get _isEditMode => widget.team != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.team!.name;
      _descriptionController.text = widget.team!.description ?? '';
      _uploadedImageFileName = widget.team!.imageFile;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sportsAsync = ref.watch(sportsListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditMode ? 'Edit Team' : 'Create Team',
          style: TextStyle(
            color: AppColors.textPrimaryLight,
            fontSize: AppResponsive.font(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppResponsive.padding(context, all: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload Section
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _isUploadingImage ? null : _pickImage,
                            child: Container(
                              width: AppResponsive.s(context, 120),
                              height: AppResponsive.s(context, 120),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.cardBorderLight,
                                  width: 2,
                                ),
                              ),
                              child: _buildImagePreview(),
                            ),
                          ),
                          SizedBox(height: AppResponsive.s(context, 12)),
                          TextButton.icon(
                            onPressed: _isUploadingImage ? null : _pickImage,
                            icon: _isUploadingImage
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.accentBlue,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.upload,
                                    color: AppColors.accentBlue,
                                  ),
                            label: Text(
                              _isUploadingImage
                                  ? 'Uploading...'
                                  : 'Upload Team Logo',
                              style: TextStyle(
                                color: AppColors.accentBlue,
                                fontSize: AppResponsive.font(context, 14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppResponsive.s(context, 24)),

                    // Team Name
                    AppTextFieldWithLabel(
                      label: 'Team Name',
                      hintText: 'Enter team name',
                      controller: _nameController,
                      isRequired: true,
                      maxLength: 50,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Team name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppResponsive.s(context, 16)),

                    // Sport Dropdown
                    sportsAsync.when(
                      data: (sports) {
                        // Pre-select sport in edit mode
                        if (_isEditMode &&
                            _selectedSport == null &&
                            widget.team!.sportId > 0) {
                          try {
                            _selectedSport = sports.firstWhere(
                              (s) => s.sportsId == widget.team!.sportId,
                            );
                          } catch (_) {}
                        }

                        return AppDropdownFormField<dynamic>(
                          label: 'Sport',
                          items: sports,
                          itemLabel: (sport) => sport.sportsName,
                          value: _selectedSport,
                          hint: 'Select sport',
                          onChanged: (value) {
                            setState(() {
                              _selectedSport = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a sport';
                            }
                            return null;
                          },
                        );
                      },
                      loading: () => AppDropdownFormField<dynamic>(
                        label: 'Sport',
                        items: const [],
                        itemLabel: (item) => '',
                        value: null,
                        hint: 'Loading sports...',
                        onChanged: null,
                        isLoading: true,
                      ),
                      error: (error, stack) => AppDropdownFormField<dynamic>(
                        label: 'Sport',
                        items: const [],
                        itemLabel: (item) => '',
                        value: null,
                        hint: 'Failed to load sports',
                        onChanged: null,
                      ),
                    ),
                    SizedBox(height: AppResponsive.s(context, 16)),

                    // Description
                    AppTextFieldWithLabel(
                      label: 'Description',
                      hintText: 'Enter team description (optional)',
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 200,
                      isRequired: false,
                    ),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: AppResponsive.padding(context, all: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: AppButton(
                  text: _isEditMode ? 'Update Team' : 'Create Team',
                  onPressed: _isLoading || _isUploadingImage ? null : _saveTeam,
                  isLoading: _isLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_isUploadingImage) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
        ),
      );
    }

    if (_profileImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          _profileImage!,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_uploadedImageFileName != null && _uploadedImageFileName!.isNotEmpty) {
      final config = AppConfig.load();
      final imageUrl =
          '${config.apiBaseUrl}${ApiEndpoints.sportsUploads}$_uploadedImageFileName';
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: Icon(
              Icons.shield_outlined,
              size: AppResponsive.s(context, 48),
              color: AppColors.textMutedLight,
            ),
          ),
          errorWidget: (context, url, error) => Center(
            child: Icon(
              Icons.shield_outlined,
              size: AppResponsive.s(context, 48),
              color: AppColors.textMutedLight,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        Icons.shield_outlined,
        size: AppResponsive.s(context, 48),
        color: AppColors.textMutedLight,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final croppedImage = await ImagePickerHelper.pickAndCropImage(
        context: context,
        source: ImageSource.gallery,
        aspectRatioPreset: ImageAspectRatioPreset.square,
        cropShape: ImageCropShape.rectangle,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 90,
      );

      if (croppedImage != null) {
        setState(() {
          _profileImage = croppedImage;
          _isUploadingImage = true;
        });

        // Upload the image immediately
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
            print('✅ [CreateTeam] Image uploaded: $uploadedFileName');
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
        }
      }
    } catch (e) {
      if (mounted) {
        await AppDialogs.showError(
          context,
          message: 'Failed to pick image. Please try again.',
          title: 'Error',
        );
      }
    }
  }

  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Wait for image upload if still in progress
    if (_isUploadingImage) {
      await AppDialogs.showError(
        context,
        message: 'Please wait for image upload to complete',
        title: 'Upload in Progress',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = SaveTeamRequest(
        id: _isEditMode ? widget.team!.id : null,
        name: _nameController.text.trim(),
        sportId: _selectedSport?.sportsId ?? 0,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageFile: _uploadedImageFileName,
      );

      final repository = ref.read(teamsRepositoryProvider);
      await repository.saveTeam(request);

      if (mounted) {
        setState(() => _isLoading = false);

        await AppDialogs.showSuccess(
          context,
          message: _isEditMode
              ? 'Team updated successfully!'
              : 'Team created successfully!',
          title: 'Success',
        );

        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        await AppDialogs.showError(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          title: 'Error',
        );
      }
    }
  }
}
