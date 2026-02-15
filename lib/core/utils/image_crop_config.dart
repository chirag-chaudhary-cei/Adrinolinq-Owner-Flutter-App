/// Image aspect ratio presets for different use cases.
enum ImageAspectRatioPreset {
  /// 1:1 aspect ratio (for profile pictures)
  square,

  /// 16:9 aspect ratio (for banners/tournaments)
  ratio16x9,

  /// 4:3 aspect ratio (for cards)
  ratio4x3,

  /// Free aspect ratio
  free,
}

/// Crop shape for the image.
enum ImageCropShape {
  /// Circular crop (for avatars)
  circle,

  /// Rectangular crop (for banners/cards)
  rectangle,
}
