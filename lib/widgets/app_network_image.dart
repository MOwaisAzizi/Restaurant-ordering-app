import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const _ImageFallback(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
      errorBuilder: (_, _, _) {
        return const _ImageFallback(child: Icon(Icons.restaurant, size: 36));
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.cardElevated,
      child: Center(child: child),
    );
  }
}
