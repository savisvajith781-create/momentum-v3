import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool highlighted;
  final Gradient? gradient;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.highlighted = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: gradient != null ? null : (backgroundColor ?? AppColors.surface),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: highlighted
              ? AppColors.primary.withOpacity(0.5)
              : (borderColor ?? AppColors.border),
          width: highlighted ? 1.5 : 1,
        ),
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: Colors.white.withOpacity(0.04),
          highlightColor: Colors.white.withOpacity(0.04),
          splashColor: AppColors.primary.withOpacity(0.08),
          child: content,
        ),
      );
    }

    return content;
  }
}
