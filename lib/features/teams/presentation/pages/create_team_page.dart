import 'dart:io';

import 'package:adrinolinq_owner/core/widgets/app_dropdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors_new.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/utils/image_crop_config.dart';
import '../../../../core/utils/image_picker_helper.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_text_field_with_label.dart';
import '../../../../core/widgets/global_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/providers/onboarding_providers.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            GlobalAppBar(
              title: _isEditMode ? 'Edit Team' : 'Create Team',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppResponsive.padding(context, all: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Upload Section - Onboarding Style
                      _buildImageUploadSection(),
                      SizedBox(height: AppResponsive.s(context, 24)),

                      // Team Name
                      AppTextFieldWithLabel(
                        label: 'Team Name',
                        hintText: 'Enter team name',
                        controller: _nameController,
                        isRequired: true,
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
                            final match = sports
                                .where(
                                  (s) => s.sportsId == widget.team!.sportId,
                                )
                                .firstOrNull;
                            if (match != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() => _selectedSport = match);
                                }
                              });
                            }
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
                        isRequired: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Save Button
            Container(
              padding: AppResponsive.padding(context, all: 20),
              color: Colors.transparent,
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

  Widget _buildImageUploadSection() {
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
                  onTap: _isUploadingImage ? null : _pickImage,
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
                if (_isUploadingImage)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: AppResponsive.borderRadius(context, 12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppLoading.circular(color: Colors.white),
                            SizedBox(height: AppResponsive.s(context, 12)),
                            Text(
                              'Uploading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppResponsive.font(context, 14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                      onTap: _isUploadingImage ? null : _pickImage,
                      child: ClipRRect(
                        borderRadius: AppResponsive.borderRadius(context, 12),
                        child: Builder(
                          builder: (context) {
                            final repository =
                                ref.read(teamsRepositoryProvider);
                            final imageUrl = repository
                                .getTeamImageUrl(_uploadedImageFileName);
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
                            Icons.shield_outlined,
                            size: AppResponsive.icon(context, 36),
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppResponsive.s(context, 10)),
                    Text(
                      'Upload Team Logo',
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
                      onTap: _isUploadingImage ? null : _pickImage,
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

  Future<void> _pickImage() async {
    try {
      final croppedImage = await ImagePickerHelper.pickAndCropImage(
        context: context,
        source: ImageSource.gallery,
        aspectRatioPreset: ImageAspectRatioPreset.square,
        cropShape: ImageCropShape.rectangle,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
      );

      if (croppedImage != null) {
        setState(() {
          _profileImage = croppedImage;
          _isUploadingImage = true;
        });

        // Upload the image immediately
        try {
          final repository = ref.read(teamsRepositoryProvider);
          final uploadedFileName = await repository.uploadTeamImage(
            croppedImage,
          );

          if (mounted) {
            setState(() {
              _uploadedImageFileName = uploadedFileName;
              _isUploadingImage = false;
            });
            print('✅ [CreateTeam] Team image uploaded: $uploadedFileName');
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
