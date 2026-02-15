import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:adrinolinq_owner/core/widgets/crop_image_page.dart';
import 'package:adrinolinq_owner/core/utils/image_crop_config.dart';

/// Helper class for picking and cropping images
class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from the specified source and crop it
  ///
  /// [source] - ImageSource.gallery or ImageSource.camera
  /// [aspectRatioPreset] - The aspect ratio to enforce during cropping
  /// [cropShape] - Circle or rectangle crop shape
  /// [maxWidth] - Maximum width of the picked image (before cropping)
  /// [maxHeight] - Maximum height of the picked image (before cropping)
  /// [imageQuality] - Quality of the picked image (0-100)
  ///
  /// Returns the cropped image file or null if cancelled
  static Future<File?> pickAndCropImage({
    required BuildContext context,
    required ImageSource source,
    ImageAspectRatioPreset aspectRatioPreset = ImageAspectRatioPreset.ratio16x9,
    ImageCropShape cropShape = ImageCropShape.rectangle,
    int maxWidth = 2048, // Increased default for better quality
    int maxHeight = 2048, // Increased default for better quality
    int imageQuality = 95, // Increased default quality
  }) async {
    try {
      // Pick the image with high quality settings
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile == null) {
        return null;
      }

      final Uint8List imageBytes = await File(pickedFile.path).readAsBytes();
      if (!context.mounted) {
        return null;
      }

      return Navigator.of(context).push<File?>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => CropImagePage(
            imageBytes: imageBytes,
            aspectRatioPreset: aspectRatioPreset,
            cropShape: cropShape,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error picking/cropping image: $e');
      return null;
    }
  }

  /// Pick an image for profile (circular, 1:1 aspect ratio)
  static Future<File?> pickProfileImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    return pickAndCropImage(
      context: context,
      source: source,
      aspectRatioPreset: ImageAspectRatioPreset.square,
      cropShape: ImageCropShape.circle,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );
  }

  /// Pick an image for banners/tournaments (rectangular, 16:9 aspect ratio)
  static Future<File?> pickBannerImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    return pickAndCropImage(
      context: context,
      source: source,
      aspectRatioPreset: ImageAspectRatioPreset.ratio16x9,
      cropShape: ImageCropShape.rectangle,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
  }

  /// Pick an image for cards (rectangular, 4:3 aspect ratio)
  static Future<File?> pickCardImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    return pickAndCropImage(
      context: context,
      source: source,
      aspectRatioPreset: ImageAspectRatioPreset.ratio4x3,
      cropShape: ImageCropShape.rectangle,
      maxWidth: 1200,
      maxHeight: 900,
      imageQuality: 85,
    );
  }
}
