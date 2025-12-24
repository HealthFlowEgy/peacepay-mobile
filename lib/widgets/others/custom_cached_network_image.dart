import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';
import 'custom_loading_widget.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.placeHolder,
    this.height,
    this.width,
    this.isCircle = false,
    this.radius,
  });

  final String imageUrl;
  final Widget? placeHolder;
  final double? height;
  final double? width;
  final double? radius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: height ?? double.infinity,
      width: width ?? double.infinity,
      imageUrl: imageUrl,
      // Performance optimization: Add memory cache configuration
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      maxHeightDiskCache: 1000,
      maxWidthDiskCache: 1000,
      imageBuilder: (context, imageProvider) => Container(
        height: height ?? double.infinity,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle
              ? null
              : BorderRadius.circular(Dimensions.radius * (radius ?? 1.2)),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit
                .cover, // Changed from fill to cover for better performance
          ),
        ),
      ),
      placeholder: (context, url) => placeHolder ?? const CustomLoadingWidget(),
      errorWidget: (context, url, error) =>
          placeHolder ?? const Icon(Icons.error),
      // Performance: Fade in animation
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }
}
