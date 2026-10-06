import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.width,
    this.height,
  });

  final String? url;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(child: Icon(Icons.image_outlined, color: scheme.outline)),
    );
    final address = url;
    Widget child = (address == null || address.isEmpty)
        ? placeholder
        : CachedNetworkImage(
            imageUrl: address,
            fit: fit,
            width: width,
            height: height,
            placeholder: (context, imageUrl) => placeholder,
            errorWidget: (context, imageUrl, error) => placeholder,
          );
    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
