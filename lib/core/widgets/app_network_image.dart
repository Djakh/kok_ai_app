import 'package:flutter/material.dart';
import 'package:kok_ai_app/core/network/api_config.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.imageUrl,
    required this.fallback,
    super.key,
    this.fit,
    this.width,
    this.height,
  });

  final String? imageUrl;
  final Widget fallback;
  final BoxFit? fit;
  final double? width;
  final double? height;

  /// --- Widgets ---

  Widget get imageWidget {
    final resolvedImageUrl = ApiConfig.normalizeAssetUrl(imageUrl);
    if (resolvedImageUrl == null) return fallback;

    return Image.network(
      resolvedImageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => fallback,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return fallback;
      },
    );
  }

  @override
  Widget build(BuildContext context) => imageWidget;
}
