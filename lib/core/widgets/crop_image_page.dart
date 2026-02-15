import 'dart:io';
import 'dart:typed_data';

import 'package:adrinolinq_owner/core/utils/image_crop_config.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CropImagePage extends StatefulWidget {
  const CropImagePage({
    super.key,
    required this.imageBytes,
    required this.aspectRatioPreset,
    required this.cropShape,
  });

  final Uint8List imageBytes;
  final ImageAspectRatioPreset aspectRatioPreset;
  final ImageCropShape cropShape;

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final CropController _controller = CropController();
  bool _isCropping = false;

  double? get _aspectRatio {
    switch (widget.aspectRatioPreset) {
      case ImageAspectRatioPreset.square:
        return 1;
      case ImageAspectRatioPreset.ratio16x9:
        return 16 / 9;
      case ImageAspectRatioPreset.ratio4x3:
        return 4 / 3;
      case ImageAspectRatioPreset.free:
        return null;
    }
  }

  Future<File> _persistCroppedBytes(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final isCircle = widget.cropShape == ImageCropShape.circle;
    final extension = isCircle ? 'png' : 'jpg';
    final file = File(
      '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  void _startCrop() {
    if (_isCropping) return;
    setState(() => _isCropping = true);

    if (widget.cropShape == ImageCropShape.circle) {
      _controller.cropCircle();
    } else {
      _controller.crop();
    }
  }

  Future<void> _handleCropped(CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        final file = await _persistCroppedBytes(croppedImage);
        if (!mounted) return;
        Navigator.of(context).pop<File?>(file);
      case CropFailure(:final cause):
        if (!mounted) return;
        setState(() => _isCropping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to crop image : $cause')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scrim = colorScheme.scrim;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        leading: IconButton(
          onPressed:
              _isCropping ? null : () => Navigator.of(context).pop<File?>(null),
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            onPressed: _isCropping ? null : _startCrop,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Crop(
                image: widget.imageBytes,
                controller: _controller,
                aspectRatio: _aspectRatio,
                withCircleUi: widget.cropShape == ImageCropShape.circle,
                interactive: true,
                baseColor: colorScheme.surface,
                maskColor: scrim.withOpacity(0.55),
                onCropped: _handleCropped,
              ),
            ),
            if (_isCropping)
              Positioned.fill(
                child: ColoredBox(
                  color: scrim.withOpacity(0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
